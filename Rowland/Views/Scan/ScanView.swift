import SwiftUI
import VisionKit
import PhotosUI

// MARK: - Scan View
//
// Primary entry point for the AI photo identification feature.
// Flow: Camera → detect stamp rectangle → extract embedding → match → ScanResultView
//
// Uses VisionKit DataScannerViewController for camera pipeline.
// Falls back to photo library picker if camera unavailable.

struct ScanView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ScanViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.stampSurface.ignoresSafeArea()

                switch viewModel.state {
                case .idle:
                    CameraIdleView(viewModel: viewModel)

                case .scanning:
                    LiveScannerView(viewModel: viewModel)

                case .processing:
                    ProcessingView()

                case .processingPages(let progress):
                    PageProcessingView(progress: progress, viewModel: viewModel)

                case .result(let result):
                    ScanResultView(result: result, viewModel: viewModel)

                case .pageResults(let pages):
                    PageResultsView(pages: pages, viewModel: viewModel)

                case .error(let message):
                    ScanErrorView(message: message, viewModel: viewModel)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotoPickerButton(viewModel: viewModel)
                }
                ToolbarItem(placement: .topBarLeading) {
                    switch viewModel.state {
                    case .result, .pageResults:
                        Button("New Scan") { viewModel.resetScan() }
                            .foregroundColor(.stampGold)
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }

    private var title: String {
        switch viewModel.state {
        case .pageResults(let pages):
            let count = pages.reduce(0) { $0 + $1.stamps.count }
            return "\(count) Stamp\(count == 1 ? "" : "s") Found"
        case .processingPages:
            return "Reading Page"
        default:
            return "Scan Stamp"
        }
    }
}

// MARK: - Idle State (pre-scan prompt)

private struct CameraIdleView: View {
    @ObservedObject var viewModel: ScanViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Animated stamp viewfinder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.stampGold.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .frame(width: 240, height: 240)

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 80))
                    .foregroundColor(.stampGold.opacity(0.6))
            }

            VStack(spacing: 12) {
                Text("Scan a stamp or a whole page")
                    .font(.title2).fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                Text("Photograph a single stamp, or an entire album page —\nRowland finds every stamp on it and identifies each one.")
                    .font(.subheadline).foregroundColor(.stampMuted)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    viewModel.startScanning()
                } label: {
                    Label("Open Camera", systemImage: "camera.fill")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.stampGold)
                        .cornerRadius(14)
                }

                PagePickerButton(viewModel: viewModel)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Page Picker (existing photos, one or many)

private struct PagePickerButton: View {
    @ObservedObject var viewModel: ScanViewModel
    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 50,
            selectionBehavior: .ordered,
            matching: .images
        ) {
            Label("Choose Photos", systemImage: "photo.stack")
                .font(.headline)
                .foregroundColor(.stampGold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.stampCard)
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.stampBorder))
                .cornerRadius(14)
        }
        .onChange(of: selectedItems) { _, items in
            guard !items.isEmpty else { return }
            Task {
                var images: [UIImage] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                selectedItems = []
                guard !images.isEmpty else { return }
                viewModel.identifyPages(images)
            }
        }
    }
}

// MARK: - Page Processing (progress across a batch)

private struct PageProcessingView: View {
    let progress: BatchProgress
    @ObservedObject var viewModel: ScanViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if let fraction = progress.fraction {
                ProgressView(value: fraction)
                    .tint(.stampGold)
                    .frame(width: 220)
                Text("Identifying \(progress.stampsDone) of \(progress.stampsFound) stamps")
                    .font(.subheadline).foregroundColor(.stampMuted)
            } else {
                ProgressView().scaleEffect(1.5).tint(.stampGold)
                Text("Finding stamps on the page…")
                    .font(.subheadline).foregroundColor(.stampMuted)
            }

            if progress.isMultiPage {
                Text("Page \(progress.pageIndex + 1) of \(progress.pageCount)")
                    .font(.footnote).foregroundColor(.stampMuted)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.stampCard)
                    .cornerRadius(20)
            }

            Spacer()

            Button("Cancel") { viewModel.cancelBatch() }
                .foregroundColor(.stampMuted)
                .padding(.bottom, 32)
        }
    }
}

// MARK: - Live Scanner (VisionKit)

private struct LiveScannerView: View {
    @ObservedObject var viewModel: ScanViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            // DataScanner wraps VisionKit DataScannerViewController
            DataScannerRepresentable(viewModel: viewModel)
                .ignoresSafeArea()

            // Overlay UI
            VStack(spacing: 0) {
                Spacer()

                // Instruction banner
                Text("Hold steady — frame the stamp")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.bottom, 32)

                // Capture button
                Button {
                    viewModel.captureCurrentFrame()
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 72, height: 72)
                        .overlay(Circle().fill(Color.stampGold).frame(width: 58, height: 58))
                }
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - DataScanner UIViewControllerRepresentable

import VisionKit

private struct DataScannerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ScanViewModel

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [],   // No text/barcode recognition — image only
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isGuidanceEnabled: true,
            isHighlightingEnabled: false
        )
        scanner.delegate = context.coordinator
        viewModel.scannerController = scanner
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(viewModel: viewModel) }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let viewModel: ScanViewModel
        init(viewModel: ScanViewModel) { self.viewModel = viewModel }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            // TODO: Handle tapped items if using text recognition for catalogue lookup
        }
    }
}

// MARK: - Processing State

private struct ProcessingView: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.stampGold)
            Text("Identifying stamp...")
                .font(.subheadline)
                .foregroundColor(.stampMuted)
        }
    }
}

// MARK: - Error State

private struct ScanErrorView: View {
    let message: String
    @ObservedObject var viewModel: ScanViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.stampMuted)
            Button("Try Again") { viewModel.resetScan() }
                .foregroundColor(.stampGold)
        }
        .padding(32)
    }
}

// MARK: - Photo Picker Button

private struct PhotoPickerButton: View {
    @ObservedObject var viewModel: ScanViewModel
    @State private var selectedItems: [PhotosPickerItem] = []

    /// Generous but bounded: enough for a full album in one go, low enough that a
    /// mis-tap on "Select All" in Photos doesn't queue a thousand images.
    private let maxPages = 50

    var body: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: maxPages,
            selectionBehavior: .ordered,
            matching: .images
        ) {
            Image(systemName: "photo.on.rectangle")
                .foregroundColor(.stampGold)
        }
        .onChange(of: selectedItems) { _, items in
            guard !items.isEmpty else { return }
            Task {
                var images: [UIImage] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                selectedItems = []
                guard !images.isEmpty else { return }
                // Page mode handles both cases: a single close-up resolves to one detection.
                viewModel.identifyPages(images)
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class ScanViewModel: ObservableObject {
    enum State {
        case idle
        case scanning
        case processing
        /// Locating and identifying stamps across one or more page images.
        case processingPages(BatchProgress)
        case result(ScanResult)
        /// One or more pages, each with every stamp found on it.
        case pageResults([PageScan])
        case error(String)
    }

    @Published var state: State = .idle

    var scannerController: DataScannerViewController?
    private let classifier: StampClassifier
    private let api: StampAPIClient
    private var batchTask: Task<Void, Never>?

    init() {
        self.classifier = StampClassifier()
        self.api = StampAPIClient()
    }

    func startScanning() {
        state = .scanning
        Task {
            try? scannerController?.startScanning()
        }
    }

    func captureCurrentFrame() {
        guard case .scanning = state else { return }
        scannerController?.stopScanning()

        // Capture the current camera frame
        // TODO: Add UIImagePickerController or AVCaptureSession frame grab
        // For now, transition to processing state
        state = .processing
    }

    func identifyImage(_ image: UIImage) async {
        state = .processing
        do {
            let result = try await classifier.identify(image: image)
            state = .result(result)

            // Log the scan for ML training data (fire and forget)
            Task {
                try? await api.logScan(
                    imageKey: nil,
                    matchedStampID: result.stamp.stampID,
                    confidence: result.confidence,
                    topCandidates: result.topCandidates.map { ($0.stamp.stampID, $0.score) },
                    modelVersion: "v1.0"
                )
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Page & Batch Scanning

    /// Identify every stamp across one or more page images.
    ///
    /// Pages are processed in order and results accumulate, so a failure on page 3 still
    /// leaves pages 1 and 2 usable rather than discarding the whole batch.
    func identifyPages(_ images: [UIImage]) {
        guard !images.isEmpty else { return }

        batchTask?.cancel()
        batchTask = Task {
            var progress = BatchProgress(pageIndex: 0, pageCount: images.count)
            state = .processingPages(progress)

            var pages: [PageScan] = []
            var failures: [String] = []

            for (index, image) in images.enumerated() {
                if Task.isCancelled { return }

                progress.pageIndex = index
                progress.stampsDone = 0
                progress.stampsFound = 0
                state = .processingPages(progress)

                do {
                    let page = try await classifier.identifyPage(image: image) { done, found in
                        progress.stampsDone = done
                        progress.stampsFound = found
                        self.state = .processingPages(progress)
                    }
                    pages.append(page)
                    logScans(for: page)
                } catch {
                    failures.append("Page \(index + 1): \(error.localizedDescription)")
                }
            }

            if Task.isCancelled { return }

            if pages.isEmpty {
                state = .error(failures.joined(separator: "\n"))
            } else {
                state = .pageResults(pages)
            }
        }
    }

    func cancelBatch() {
        batchTask?.cancel()
        batchTask = nil
        state = .idle
    }

    /// Toggle whether a detected stamp is included in a bulk add.
    func toggleSelection(pageID: PageScan.ID, stampID: DetectedStamp.ID) {
        guard case .pageResults(var pages) = state,
              let pageIndex = pages.firstIndex(where: { $0.id == pageID }),
              let stampIndex = pages[pageIndex].stamps.firstIndex(where: { $0.id == stampID }),
              pages[pageIndex].stamps[stampIndex].outcome.result != nil
        else { return }

        pages[pageIndex].stamps[stampIndex].isSelected.toggle()
        state = .pageResults(pages)
    }

    func setAllSelected(_ isSelected: Bool) {
        guard case .pageResults(var pages) = state else { return }
        for pageIndex in pages.indices {
            for stampIndex in pages[pageIndex].stamps.indices
            where pages[pageIndex].stamps[stampIndex].outcome.result != nil {
                pages[pageIndex].stamps[stampIndex].isSelected = isSelected
            }
        }
        state = .pageResults(pages)
    }

    /// Every currently selected match across all pages.
    func selectedResults(in pages: [PageScan]) -> [ScanResult] {
        pages.flatMap { $0.stamps }.filter(\.isSelected).compactMap { $0.outcome.result }
    }

    private func logScans(for page: PageScan) {
        // Fire and forget — training signal, never blocks the user.
        let entries = page.stamps.compactMap { $0.outcome.result }
        Task {
            for result in entries {
                try? await api.logScan(
                    imageKey: nil,
                    matchedStampID: result.stamp.stampID,
                    confidence: result.confidence,
                    topCandidates: result.topCandidates.map { ($0.stamp.stampID, $0.score) },
                    modelVersion: "v1.0"
                )
            }
        }
    }

    func resetScan() {
        batchTask?.cancel()
        batchTask = nil
        state = .idle
    }
}
