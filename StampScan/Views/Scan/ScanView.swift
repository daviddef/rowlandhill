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

                case .result(let result):
                    ScanResultView(result: result, viewModel: viewModel)

                case .error(let message):
                    ScanErrorView(message: message, viewModel: viewModel)
                }
            }
            .navigationTitle("Scan Stamp")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotoPickerButton(viewModel: viewModel)
                }
                ToolbarItem(placement: .topBarLeading) {
                    if case .result = viewModel.state {
                        Button("New Scan") { viewModel.resetScan() }
                            .foregroundColor(.stampGold)
                    }
                }
            }
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
                Text("Point camera at a stamp")
                    .font(.title2).fontWeight(.semibold)
                Text("StampScan identifies stamps from any country\nin any condition using AI.")
                    .font(.subheadline).foregroundColor(.stampMuted)
                    .multilineTextAlignment(.center)
            }

            Spacer()

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
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
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
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Image(systemName: "photo.on.rectangle")
                .foregroundColor(.stampGold)
        }
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await viewModel.identifyImage(image)
                }
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
        case result(ScanResult)
        case error(String)
    }

    @Published var state: State = .idle

    var scannerController: DataScannerViewController?
    private let classifier: StampClassifier
    private let api: StampAPIClient

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

    func resetScan() {
        state = .idle
    }
}
