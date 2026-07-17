import UIKit
import CoreGraphics

// MARK: - Page Scanning Models
//
// A "page scan" is one source image (typically an album page) containing many stamps.
// Vision locates every stamp in the image; each one is then identified independently.
// A batch is several pages queued together.
//
// Single-stamp scanning is just the degenerate case: one page, one detection.

/// One stamp located inside a larger source image.
struct DetectedStamp: Identifiable {
    let id = UUID()

    /// Bounding box in Vision's normalised coordinate space (origin bottom-left, 0...1).
    /// Kept in Vision space so it can be drawn over the source image at any display size.
    let boundingBox: CGRect

    /// The cropped region, upright and ready for embedding extraction.
    let crop: UIImage

    var outcome: Outcome = .pending

    /// Whether the user wants this one added to their collection. Low-confidence
    /// matches start deselected so a bulk add doesn't silently import garbage.
    var isSelected: Bool = false

    enum Outcome {
        case pending
        case identified(ScanResult)
        case failed(String)

        var result: ScanResult? {
            if case .identified(let r) = self { return r }
            return nil
        }

        var isPending: Bool {
            if case .pending = self { return true }
            return false
        }
    }

    /// Confidence below which we don't pre-select a match for bulk add.
    /// Matches the server-fallback threshold in StampClassifier.
    static let autoSelectThreshold: Double = 0.85
}

/// One source image plus every stamp found in it.
struct PageScan: Identifiable {
    let id = UUID()
    let sourceImage: UIImage
    var stamps: [DetectedStamp]

    var identifiedCount: Int { stamps.filter { $0.outcome.result != nil }.count }
    var failedCount: Int { stamps.filter { if case .failed = $0.outcome { return true }; return false }.count }
    var selectedCount: Int { stamps.filter(\.isSelected).count }
}

// MARK: - Batch Progress

/// Progress across a multi-page batch, for the processing UI.
struct BatchProgress {
    var pageIndex: Int = 0
    var pageCount: Int = 1
    var stampsDone: Int = 0
    var stampsFound: Int = 0

    /// Nil while we're still locating stamps and don't yet know the denominator.
    var fraction: Double? {
        guard stampsFound > 0 else { return nil }
        return Double(stampsDone) / Double(stampsFound)
    }

    var isMultiPage: Bool { pageCount > 1 }
}

// MARK: - Image Helpers

extension UIImage {
    /// Redraws the image with `.up` orientation.
    ///
    /// Photos from the library and camera commonly carry an EXIF orientation of `.right`.
    /// Vision reads `cgImage` directly and ignores `imageOrientation`, so an un-normalised
    /// image yields bounding boxes rotated 90° from what the user sees. Normalising once
    /// up front keeps detection, cropping, and the on-screen overlay in one coordinate space.
    func normalizedUpright() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// Crops to a Vision-normalised rect (origin bottom-left), returning an upright image.
    ///
    /// Vision's origin is bottom-left; CGImage's is top-left. The y axis must be flipped
    /// or crops come out mirrored vertically about the image centre.
    func cropping(toVisionRect box: CGRect, insetBy inset: CGFloat = 0) -> UIImage? {
        guard let cgImage else { return nil }
        let w = CGFloat(cgImage.width)
        let h = CGFloat(cgImage.height)

        var rect = CGRect(
            x: box.minX * w,
            y: (1 - box.maxY) * h,
            width: box.width * w,
            height: box.height * h
        )
        if inset != 0 {
            rect = rect.insetBy(dx: -inset * rect.width, dy: -inset * rect.height)
        }
        rect = rect.intersection(CGRect(x: 0, y: 0, width: w, height: h))
        guard !rect.isNull, rect.width >= 1, rect.height >= 1,
              let cropped = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cropped, scale: scale, orientation: .up)
    }
}

// MARK: - Detection Cleanup

extension Array where Element == DetectedStamp {
    /// Collapses overlapping detections down to one box per physical stamp.
    ///
    /// `VNDetectRectanglesRequest` finds *rectangles*, not stamps, so a single stamp
    /// commonly yields several nested boxes: the stamp body, its printed inner frame,
    /// and any rectangular motif in the design. Measured on a 12-stamp test page, raw
    /// detection returned 34 boxes — the 12 stamps plus their inner frames. Left in,
    /// each duplicate costs an identification call and pollutes a bulk add.
    ///
    /// Greedy suppression, largest first: a box is dropped when most of it already sits
    /// inside a bigger kept box. Overlap is measured against the *smaller* box's area
    /// rather than the union, because a fully-nested inner frame scores a low IoU against
    /// its parent yet is certainly the same stamp.
    ///
    /// - Parameter overlapTolerance: fraction of the smaller box that must lie inside a
    ///   kept box before it is treated as a duplicate.
    func deduplicated(overlapTolerance: Double = 0.6) -> [DetectedStamp] {
        let sorted = self.sorted { area($0) > area($1) }
        var kept: [DetectedStamp] = []

        for candidate in sorted {
            let isDuplicate = kept.contains { existing in
                let overlap = candidate.boundingBox.intersection(existing.boundingBox)
                guard !overlap.isNull, !overlap.isEmpty else { return false }
                let smaller = Swift.min(area(candidate), area(existing))
                guard smaller > 0 else { return false }
                return (overlap.width * overlap.height) / smaller > overlapTolerance
            }
            if !isDuplicate { kept.append(candidate) }
        }
        return kept
    }

    private func area(_ stamp: DetectedStamp) -> Double {
        Double(stamp.boundingBox.width * stamp.boundingBox.height)
    }
}

// MARK: - Reading Order

extension Array where Element == DetectedStamp {
    /// Sorts detections into album reading order: top row left-to-right, then the next row.
    ///
    /// Stamps in a row are rarely pixel-aligned, so rows are banded by vertical overlap
    /// rather than exact y equality. Vision's y grows upward, so descending y is top-down.
    func inReadingOrder() -> [DetectedStamp] {
        guard !isEmpty else { return [] }

        let sorted = self.sorted { $0.boundingBox.midY > $1.boundingBox.midY }
        var rows: [[DetectedStamp]] = []

        for stamp in sorted {
            let bandTolerance = stamp.boundingBox.height * 0.5
            if let index = rows.indices.last,
               let reference = rows[index].first,
               abs(reference.boundingBox.midY - stamp.boundingBox.midY) < bandTolerance {
                rows[index].append(stamp)
            } else {
                rows.append([stamp])
            }
        }

        return rows.flatMap { $0.sorted { $0.boundingBox.minX < $1.boundingBox.minX } }
    }
}
