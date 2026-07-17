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

    /// Identify a stamp from a UIImage.
    /// Returns top-5 candidates with confidence scores.
    func identify(image: UIImage) async throws -> ScanResult {
        guard isLoaded else { throw ClassifierError.modelNotLoaded }

        // 1. Pre-process image (crop to stamp region using Vision)
        let stampRegion = try await detectStampRegion(in: image)

        // 2. Extract embedding from cropped region
        let embedding = try await extractEmbedding(from: stampRegion)

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

    private func detectStampRegion(in image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else { throw ClassifierError.invalidImage }

        return try await withCheckedThrowingContinuation { continuation in
            // Use VNDetectRectanglesRequest to find the stamp boundary
            let request = VNDetectRectanglesRequest { request, error in
                if let error { return continuation.resume(throwing: error) }

                guard let results = request.results as? [VNRectangleObservation],
                      let rect = results.first else {
                    // No rectangle detected — use full image
                    return continuation.resume(returning: image)
                }

                // Crop to detected rectangle
                let croppedCGImage = cgImage.cropping(to: VNImageRectForNormalizedRect(
                    rect.boundingBox,
                    cgImage.width,
                    cgImage.height
                ))
                let cropped = croppedCGImage.map { UIImage(cgImage: $0) } ?? image
                continuation.resume(returning: cropped)
            }
            request.minimumAspectRatio = 0.3
            request.maximumAspectRatio = 1.0
            request.minimumSize = 0.1
            request.maximumObservations = 1

            let handler = VNImageRequestHandler(cgImage: cgImage)
            try? handler.perform([request])
        }
    }

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

        var errorDescription: String? {
            switch self {
            case .modelNotFound:  return "Stamp recognition model not found"
            case .modelNotLoaded: return "Model is still loading, please wait"
            case .invalidImage:   return "Could not process this image"
            case .noMatchFound:   return "No matching stamp found"
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
