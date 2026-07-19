import Vision
import CoreML
import UIKit
import Combine

// MARK: - Stamp Classifier
//
// Architecture: EfficientFormer-L1 backbone → embedding vector → cosine similarity search
//
// This is NOT a fixed-class classifier. The model outputs a 512-dimensional embedding.
// Identification works by finding the closest embedding in the Qdrant vector database.
// This means new stamps can be added to the database without retraining the model.
//
// Model file: StampEmbedder.mlpackage (to be trained + exported — see docs/ml-pipeline.md)
// Training data: MiikeMineStamps (5,056 images, 407 classes) + scraped corpus
// On-device: top 100K most common stamps (embedding DB in SQLite)
// Server-side: full 5M+ corpus (Qdrant vector DB)

@MainActor
final class StampClassifier: ObservableObject {
    private var model: VNCoreMLModel?
    private var embeddingDB: EmbeddingDatabase?
    private let api: StampAPIClient

    @Published var isLoaded: Bool = false
    @Published var loadError: Error? = nil

    init(api: StampAPIClient = StampAPIClient()) {
        self.api = api
        Task { await loadModel() }
    }

    // MARK: - Model Loading

    private func loadModel() async {
        do {
            // TODO: Replace with actual trained model once available
            // The model should be exported from Keras/PyTorch via coremltools
            // Target: EfficientFormer-L1 fine-tuned on stamp images
            // Output: 512-dim float32 embedding vector (NOT class probabilities)
            //
            // guard let modelURL = Bundle.main.url(forResource: "StampEmbedder", withExtension: "mlpackage") else {
            //     throw ClassifierError.modelNotFound
            // }
            // let compiledURL = try await MLModel.compileModel(at: modelURL)
            // let mlModel = try MLModel(contentsOf: compiledURL)
            // model = try VNCoreMLModel(for: mlModel)

            // Load on-device embedding DB (SQLite, ~100K stamps)
            embeddingDB = try await EmbeddingDatabase.load()
            isLoaded = true
        } catch {
            loadError = error
        }
    }

    // MARK: - Identification Pipeline

    /// Identify a single stamp that fills most of the frame.
    func identify(image: UIImage) async throws -> ScanResult {
        guard isLoaded else { throw ClassifierError.modelNotLoaded }

        let upright = image.normalizedUpright()
        // Largest detection wins; falls back to the whole frame if Vision finds nothing.
        let regions = try await detectStampRegions(in: upright, limit: 1)
        let stampRegion = regions.first?.crop ?? upright

        return try await identify(crop: stampRegion)
    }

    /// Identify every stamp on a page image (an album page, a stock card, a pile on a table).
    ///
    /// Detection and identification are separate phases so the UI can show "found 24 stamps"
    /// before the slower per-stamp identification starts.
    /// - Parameter onProgress: called on the main actor after each stamp resolves.
    func identifyPage(
        image: UIImage,
        onProgress: @MainActor (Int, Int) -> Void = { _, _ in }
    ) async throws -> PageScan {
        guard isLoaded else { throw ClassifierError.modelNotLoaded }

        let upright = image.normalizedUpright()
        let detections = try await detectStampRegions(in: upright, limit: 0).inReadingOrder()

        guard !detections.isEmpty else {
            throw ClassifierError.noStampsFound
        }

        var stamps = detections
        onProgress(0, stamps.count)

        // Sequential rather than a TaskGroup: identification hits the shared embedding DB
        // and may fall back to the network per stamp, and a page of 30 stamps firing 30
        // concurrent requests would be hostile to the API and to the user's battery.
        // Each await yields, so the UI stays responsive and progress ticks visibly.
        for index in stamps.indices {
            // Tick before the work, not after: otherwise the label reads "0 of 51" for the
            // whole of the first stamp and the page looks frozen.
            onProgress(index, stamps.count)
            do {
                let result = try await identify(crop: stamps[index].crop)
                stamps[index].outcome = .identified(result)
                stamps[index].isSelected = result.confidence >= DetectedStamp.autoSelectThreshold
            } catch {
                stamps[index].outcome = .failed(error.localizedDescription)
                stamps[index].isSelected = false

                // Stop the page on the first unreachable-backend error. Identification is
                // one network round trip per stamp, so without this the user waits for the
                // connection to time out once per stamp — 51 stamps × 20s is 17 minutes of
                // waiting to be told the same thing 51 times.
                if Self.isBackendUnreachable(error) {
                    let message = ClassifierError.backendUnavailable.errorDescription ?? ""
                    for remaining in index..<stamps.count {
                        stamps[remaining].outcome = .failed(message)
                        stamps[remaining].isSelected = false
                    }
                    onProgress(stamps.count, stamps.count)
                    return PageScan(sourceImage: upright, stamps: stamps)
                }
            }
            onProgress(index + 1, stamps.count)
        }

        return PageScan(sourceImage: upright, stamps: stamps)
    }

    /// True for errors that mean "the server isn't answering" rather than "this stamp didn't
    /// match". Retrying these once per stamp on a page just multiplies the wait.
    private static func isBackendUnreachable(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else { return false }
        switch urlError.code {
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed,
             .notConnectedToInternet, .networkConnectionLost, .timedOut,
             .internationalRoamingOff, .dataNotAllowed, .secureConnectionFailed:
            return true
        default:
            return false
        }
    }

    // MARK: - Core Identification

    /// Identify one already-cropped stamp image.
    private func identify(crop: UIImage) async throws -> ScanResult {
        // 2. Extract embedding from cropped region
        let embedding = try await extractEmbedding(from: crop)

        // 3. Search on-device embedding DB first (fast, offline)
        var candidates = embeddingDB?.search(embedding: embedding, topK: 10) ?? []

        // 4. If top-1 confidence < 0.85, also query server-side Qdrant for full coverage
        if candidates.first?.score ?? 0 < 0.85 {
            let serverCandidates = try await api.searchByEmbedding(embedding, topK: 5)
            candidates = mergeCandidates(local: candidates, server: serverCandidates)
        }

        guard let topMatch = candidates.first else {
            throw ClassifierError.noMatchFound
        }

        // 5. Fetch full stamp detail for top match
        let stamp = try await api.fetchStamp(id: topMatch.stampID)

        return ScanResult(
            stamp: stamp,
            confidence: topMatch.score,
            topCandidates: [] // TODO: map remaining candidates
        )
    }

    // MARK: - Vision Pipeline

    /// Locate stamps in an image. Pass `limit: 0` for no limit (page mode), `1` for single-stamp mode.
    ///
    /// The image must already be upright — Vision reads `cgImage` and ignores `imageOrientation`.
    private func detectStampRegions(in image: UIImage, limit: Int) async throws -> [DetectedStamp] {
        guard let cgImage = image.cgImage else { throw ClassifierError.invalidImage }

        let observations: [VNRectangleObservation] = try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                if let error { return continuation.resume(throwing: error) }
                continuation.resume(returning: request.results as? [VNRectangleObservation] ?? [])
            }

            // Stamps are portrait, landscape, and occasionally square, so the aspect window
            // has to be wide in both directions.
            request.minimumAspectRatio = 0.3
            request.maximumAspectRatio = 3.0

            if limit == 1 {
                // Single-stamp mode: the stamp fills the frame.
                request.minimumSize = 0.1
                request.maximumObservations = 1
            } else {
                // Page mode: one stamp on a 5×10 album page is ~2% of the frame's smaller side.
                request.minimumSize = 0.02
                request.maximumObservations = 0  // 0 = no limit
            }
            request.minimumConfidence = 0.5
            // Perforated edges and hand-held pages mean stamps are never perfectly square-on.
            request.quadratureTolerance = 30

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do { try handler.perform([request]) } catch { continuation.resume(throwing: error) }
        }

        let candidates = observations.filter { observation in
            guard limit != 1 else { return true }
            // Page mode: anything covering half the frame is the page itself, a mount, or a
            // binder edge — not one stamp among many. Left in, such a box would swallow every
            // real stamp during deduplication.
            let box = observation.boundingBox
            return Double(box.width * box.height) < Self.maxPageStampArea
        }

        return candidates.compactMap { observation -> DetectedStamp? in
            // A small outset keeps perforation tips inside the crop; the perfs carry
            // identifying information and Vision tends to box the design, not the teeth.
            guard let crop = image.cropping(toVisionRect: observation.boundingBox, insetBy: 0.02) else {
                return nil
            }
            return DetectedStamp(boundingBox: observation.boundingBox, crop: crop)
        }
        .deduplicated()
    }

    /// Upper bound on one stamp's share of a page image, used only in page mode.
    private static let maxPageStampArea: Double = 0.5

    private func extractEmbedding(from image: UIImage) async throws -> [Float] {
        // TODO: Replace with actual CoreML model inference
        // The model should output a 512-dim embedding, not class probabilities
        //
        // guard let model = model, let cgImage = image.cgImage else {
        //     throw ClassifierError.modelNotLoaded
        // }
        // let request = VNCoreMLRequest(model: model)
        // request.imageCropAndScaleOption = .centerCrop
        // let handler = VNImageRequestHandler(cgImage: cgImage)
        // try handler.perform([request])
        // let result = request.results?.first as? VNCoreMLFeatureValueObservation
        // return result?.featureValue.multiArrayValue?.toFloatArray() ?? []

        // PLACEHOLDER: returns random 512-dim vector
        return (0..<512).map { _ in Float.random(in: -1...1) }
    }

    private func mergeCandidates(
        local: [EmbeddingMatch],
        server: [EmbeddingMatch]
    ) -> [EmbeddingMatch] {
        var seen = Set(local.map(\.stampID))
        let merged = local + server.filter { seen.insert($0.stampID).inserted }
        return merged.sorted { $0.score > $1.score }
    }

    // MARK: - Errors

    enum ClassifierError: LocalizedError {
        case modelNotFound
        case modelNotLoaded
        case invalidImage
        case noMatchFound
        case noStampsFound
        case backendUnavailable

        var errorDescription: String? {
            switch self {
            case .modelNotFound:  return "Stamp recognition model not found"
            case .modelNotLoaded: return "Model is still loading, please wait"
            case .invalidImage:   return "Could not process this image"
            case .noMatchFound:   return "No matching stamp found"
            case .noStampsFound:  return "No stamps found on this page. Try better lighting, or a straight-on photo with the whole page in frame."
            case .backendUnavailable:
                return "Can't reach the stamp catalogue. Check your connection and try again."
            }
        }
    }
}

// MARK: - Embedding Match

struct EmbeddingMatch {
    let stampID: String
    let score: Double  // cosine similarity 0.0–1.0
}

// MARK: - On-Device Embedding Database

/// SQLite-backed embedding store for top 100K most common stamps.
/// Full coverage (5M+) queries go to server-side Qdrant.
final class EmbeddingDatabase {
    private var embeddings: [(stampID: String, vector: [Float])] = []

    static func load() async throws -> EmbeddingDatabase {
        let db = EmbeddingDatabase()
        // TODO: Load from bundled SQLite file
        // The DB is generated during app build from the server's Qdrant export
        // File: Resources/stamp_embeddings.sqlite (~200MB for 100K stamps × 512 dims)
        return db
    }

    func search(embedding: [Float], topK: Int) -> [EmbeddingMatch] {
        // Cosine similarity search across all stored embeddings
        let scored = embeddings.map { entry in
            (stampID: entry.stampID, score: cosineSimilarity(embedding, entry.vector))
        }
        return scored
            .sorted { $0.score > $1.score }
            .prefix(topK)
            .map { EmbeddingMatch(stampID: $0.stampID, score: Double($0.score)) }
    }

    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count else { return 0 }
        let dot = zip(a, b).reduce(0) { $0 + $1.0 * $1.1 }
        let magA = sqrt(a.reduce(0) { $0 + $1 * $1 })
        let magB = sqrt(b.reduce(0) { $0 + $1 * $1 })
        guard magA > 0, magB > 0 else { return 0 }
        return dot / (magA * magB)
    }
}
