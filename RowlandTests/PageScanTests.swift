import XCTest
import UIKit
@testable import Rowland

/// Covers the geometry that page scanning depends on.
///
/// These are regression tests for two bugs found while building page scanning:
///   1. Vision returned 34 rectangles for a 12-stamp page — every stamp's printed inner
///      frame was detected alongside the stamp body.
///   2. Crops were flipped vertically because Vision's origin is bottom-left and
///      CGImage's is top-left.
final class PageScanTests: XCTestCase {

    // MARK: - Helpers

    /// Vision-space rect (origin bottom-left, normalised).
    private func stamp(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> DetectedStamp {
        DetectedStamp(
            boundingBox: CGRect(x: x, y: y, width: w, height: h),
            crop: UIImage()
        )
    }

    private func solidImage(size: CGSize, top: UIColor, bottom: UIColor) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            top.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height / 2))
            bottom.setFill()
            ctx.fill(CGRect(x: 0, y: size.height / 2, width: size.width, height: size.height / 2))
        }
    }

    private func averageColour(of image: UIImage) -> (r: Int, g: Int, b: Int) {
        guard let cg = image.cgImage else { return (0, 0, 0) }
        let w = cg.width, h = cg.height
        var pixels = [UInt8](repeating: 0, count: w * h * 4)
        let ctx = CGContext(
            data: &pixels, width: w, height: h,
            bitsPerComponent: 8, bytesPerRow: w * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        ctx?.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        var r = 0, g = 0, b = 0
        for i in stride(from: 0, to: pixels.count, by: 4) {
            r += Int(pixels[i]); g += Int(pixels[i + 1]); b += Int(pixels[i + 2])
        }
        let n = max(w * h, 1)
        return (r / n, g / n, b / n)
    }

    // MARK: - Deduplication

    /// A stamp's printed inner frame sits fully inside the stamp body. Both are
    /// rectangles, so Vision reports both; only the outer one is the stamp.
    func testNestedInnerFrameIsCollapsedToOneStamp() {
        let body = stamp(0.1, 0.1, 0.2, 0.2)
        let innerFrame = stamp(0.13, 0.13, 0.14, 0.14)

        let result = [body, innerFrame].deduplicated()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.boundingBox, body.boundingBox, "the larger box is the stamp")
    }

    /// Adjacent stamps on a page must survive — they touch but do not overlap.
    func testAdjacentStampsAreAllKept() {
        let stamps = [
            stamp(0.10, 0.10, 0.15, 0.18),
            stamp(0.30, 0.10, 0.15, 0.18),
            stamp(0.50, 0.10, 0.15, 0.18),
        ]

        XCTAssertEqual(stamps.deduplicated().count, 3)
    }

    /// Mirrors the real measurement: a 3x4 page yields body + inner frame per stamp.
    func testPageOfTwelveWithInnerFramesCollapsesToTwelve() {
        var raw: [DetectedStamp] = []
        for row in 0..<4 {
            for col in 0..<3 {
                let x = 0.1 + Double(col) * 0.27
                let y = 0.1 + Double(row) * 0.21
                raw.append(stamp(x, y, 0.19, 0.17))            // body
                raw.append(stamp(x + 0.03, y + 0.025, 0.13, 0.12))  // inner frame
            }
        }
        XCTAssertEqual(raw.count, 24)
        XCTAssertEqual(raw.deduplicated().count, 12)
    }

    /// Slight jitter between two detections of the same stamp should still collapse.
    func testNearDuplicateBoxesCollapse() {
        let a = stamp(0.100, 0.100, 0.200, 0.200)
        let b = stamp(0.105, 0.104, 0.196, 0.198)

        XCTAssertEqual([a, b].deduplicated().count, 1)
    }

    // MARK: - Reading Order

    /// Vision's y grows upward, so the top row has the *highest* y.
    /// Expected order is top row left-to-right, then the row beneath.
    func testReadingOrderIsTopRowLeftToRight() {
        let topLeft = stamp(0.1, 0.7, 0.15, 0.15)
        let topRight = stamp(0.6, 0.7, 0.15, 0.15)
        let bottomLeft = stamp(0.1, 0.2, 0.15, 0.15)
        let bottomRight = stamp(0.6, 0.2, 0.15, 0.15)

        let ordered = [bottomRight, topLeft, bottomLeft, topRight].inReadingOrder()

        XCTAssertEqual(ordered.map(\.boundingBox), [
            topLeft.boundingBox, topRight.boundingBox,
            bottomLeft.boundingBox, bottomRight.boundingBox,
        ])
    }

    /// Stamps in a row are never perfectly aligned; a small vertical wobble must not
    /// split one row into several.
    func testReadingOrderTreatsSlightlyMisalignedStampsAsOneRow() {
        let a = stamp(0.1, 0.70, 0.15, 0.15)
        let b = stamp(0.4, 0.72, 0.15, 0.15)   // 2% higher
        let c = stamp(0.7, 0.69, 0.15, 0.15)   // 1% lower

        let ordered = [c, a, b].inReadingOrder()

        XCTAssertEqual(ordered.map { $0.boundingBox.minX }, [0.1, 0.4, 0.7])
    }

    // MARK: - Cropping (Vision → CGImage coordinate flip)

    /// Vision's origin is bottom-left; CGImage's is top-left. Cropping the *top* half in
    /// Vision space (y: 0.5...1.0) must return the top half of the visible image.
    /// Before the flip was added this returned the bottom half.
    func testCroppingTopHalfInVisionSpaceReturnsVisibleTopHalf() throws {
        let image = solidImage(size: CGSize(width: 100, height: 100), top: .red, bottom: .blue)

        let topInVisionSpace = CGRect(x: 0, y: 0.5, width: 1, height: 0.5)
        let cropped = try XCTUnwrap(image.cropping(toVisionRect: topInVisionSpace))

        let colour = averageColour(of: cropped)
        XCTAssertGreaterThan(colour.r, 200, "expected the red top half")
        XCTAssertLessThan(colour.b, 55, "should not contain the blue bottom half")
    }

    func testCroppingBottomHalfInVisionSpaceReturnsVisibleBottomHalf() throws {
        let image = solidImage(size: CGSize(width: 100, height: 100), top: .red, bottom: .blue)

        let bottomInVisionSpace = CGRect(x: 0, y: 0, width: 1, height: 0.5)
        let cropped = try XCTUnwrap(image.cropping(toVisionRect: bottomInVisionSpace))

        let colour = averageColour(of: cropped)
        XCTAssertGreaterThan(colour.b, 200, "expected the blue bottom half")
        XCTAssertLessThan(colour.r, 55, "should not contain the red top half")
    }

    /// The outset must not push the crop outside the image and produce a null rect.
    func testCroppingAtImageEdgeWithOutsetStaysInBounds() throws {
        let image = solidImage(size: CGSize(width: 100, height: 100), top: .red, bottom: .blue)

        let edge = CGRect(x: 0, y: 0, width: 0.2, height: 0.2)
        let cropped = try XCTUnwrap(image.cropping(toVisionRect: edge, insetBy: 0.5))

        XCTAssertGreaterThan(cropped.size.width, 0)
        XCTAssertGreaterThan(cropped.size.height, 0)
    }
}
