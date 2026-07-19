import SwiftUI

// MARK: - Page Results View
//
// Shown after scanning one or more album pages. Each page is displayed with every
// detected stamp boxed on the source image, so the user can see what was found and
// what was missed, then bulk-add the matches they accept.
//
// Low-confidence matches arrive deselected — a bulk add must never quietly import
// guesses into someone's inventory.

struct PageResultsView: View {
    let pages: [PageScan]
    @ObservedObject var viewModel: ScanViewModel
    @EnvironmentObject var appState: AppState

    @State private var detailStamp: Stamp?
    @State private var addedCount: Int?

    private var allStamps: [DetectedStamp] { pages.flatMap(\.stamps) }
    private var identifiedCount: Int { allStamps.filter { $0.outcome.result != nil }.count }
    private var unrecognisedCount: Int { allStamps.count - identifiedCount }
    private var selectedCount: Int { allStamps.filter(\.isSelected).count }

    /// True when nothing was identified because we never reached the catalogue. "Unrecognised"
    /// would claim we searched and came up empty, which is a claim about our coverage we have
    /// no right to make when the lookup never happened.
    private var lookupUnavailable: Bool {
        identifiedCount == 0 && !allStamps.isEmpty && allStamps.allSatisfy {
            if case .failed(let reason) = $0.outcome {
                return reason == StampClassifier.ClassifierError.backendUnavailable.errorDescription
            }
            return false
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    SummaryHeader(
                        identified: identifiedCount,
                        unrecognised: unrecognisedCount,
                        selected: selectedCount,
                        lookupUnavailable: lookupUnavailable,
                        onSelectAll: { viewModel.setAllSelected(true) },
                        onSelectNone: { viewModel.setAllSelected(false) }
                    )

                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        PageSection(
                            page: page,
                            pageNumber: index + 1,
                            showPageNumber: pages.count > 1,
                            onToggle: { stampID in
                                viewModel.toggleSelection(pageID: page.id, stampID: stampID)
                            },
                            onOpenDetail: { detailStamp = $0 }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 120)  // clear the sticky add bar
            }

            if selectedCount > 0 {
                AddBar(count: selectedCount) { addSelected() }
            }
        }
        .background(Color.stampSurface)
        .navigationDestination(item: $detailStamp) { stamp in
            StampDetailView(stamp: stamp)
        }
        .alert("Added to Collection", isPresented: Binding(
            get: { addedCount != nil },
            set: { if !$0 { addedCount = nil } }
        )) {
            Button("Done") { viewModel.resetScan() }
            Button("Keep Reviewing", role: .cancel) {}
        } message: {
            Text("\(addedCount ?? 0) stamp\(addedCount == 1 ? "" : "s") added.")
        }
    }

    private func addSelected() {
        let results = viewModel.selectedResults(in: pages)
        guard !results.isEmpty else { return }

        let ids = appState.collectionStore.nextLocalIDs(count: results.count)
        let items = zip(ids, results).map { id, result in
            CollectionItem(
                id: id,
                stamp: result.stamp,
                // Condition is user-declared, never inferred: a photo cannot see gum,
                // thins, or regumming. Defaults to unset-but-plausible and is edited later.
                condition: .fine,
                isUsed: true,
                quantity: 1,
                purchasePrice: nil,
                purchaseDate: nil,
                notes: nil,
                userImageURL: nil
            )
        }
        appState.collectionStore.add(items)
        addedCount = items.count
    }
}

// MARK: - Summary Header

private struct SummaryHeader: View {
    let identified: Int
    let unrecognised: Int
    let selected: Int
    let lookupUnavailable: Bool
    let onSelectAll: () -> Void
    let onSelectNone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if lookupUnavailable {
                // Nothing was looked up, so report the detection — which did work — and be
                // explicit that identification never ran. Anything else overstates a failure
                // as a coverage gap.
                Label("\(unrecognised) stamps found, none checked",
                      systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.stampGold)
                    .font(.subheadline.weight(.medium))

                Text("The catalogue couldn't be reached, so these haven't been identified yet. "
                     + "Your stamps were detected fine — try again when you're back online.")
                    .font(.footnote)
                    .foregroundColor(.stampMuted)
            } else {
                HStack(spacing: 8) {
                    Label("\(identified) identified", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.stampGold)
                    if unrecognised > 0 {
                        Text("·").foregroundColor(.stampMuted)
                        Text("\(unrecognised) unrecognised").foregroundColor(.stampMuted)
                    }
                }
                .font(.subheadline.weight(.medium))

                Text("Check each match before adding. Tap a stamp to see its full details.")
                    .font(.footnote)
                    .foregroundColor(.stampMuted)

                HStack(spacing: 12) {
                    Button("Select All", action: onSelectAll)
                    Button("Select None", action: onSelectNone)
                }
                .font(.footnote.weight(.medium))
                .foregroundColor(.stampGold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.stampCard)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.stampBorder))
    }
}

// MARK: - One Page

private struct PageSection: View {
    let page: PageScan
    let pageNumber: Int
    let showPageNumber: Bool
    let onToggle: (DetectedStamp.ID) -> Void
    let onOpenDetail: (Stamp) -> Void

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showPageNumber {
                Text("Page \(pageNumber)")
                    .font(.headline)
                    .foregroundColor(.text)
            }

            PageOverlayImage(page: page)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(page.stamps) { stamp in
                    DetectedStampCell(
                        stamp: stamp,
                        onToggle: { onToggle(stamp.id) },
                        onOpenDetail: onOpenDetail
                    )
                }
            }
        }
    }
}

/// The source page with every detection boxed, so misses are visible.
private struct PageOverlayImage: View {
    let page: PageScan

    private var aspect: CGFloat {
        let size = page.sourceImage.size
        guard size.height > 0 else { return 1 }
        return size.width / size.height
    }

    var body: some View {
        ZStack {
            Image(uiImage: page.sourceImage)
                .resizable()

            GeometryReader { geo in
                ForEach(page.stamps) { stamp in
                    let frame = viewRect(for: stamp.boundingBox, in: geo.size)
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(colour(for: stamp), lineWidth: 2)
                        .frame(width: frame.width, height: frame.height)
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        // Constrain the container to the image's aspect ratio so the overlay's
        // coordinate space matches the drawn image exactly, with no letterboxing.
        .aspectRatio(aspect, contentMode: .fit)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.stampBorder))
    }

    /// Vision's boundingBox is normalised with a bottom-left origin; SwiftUI's is top-left.
    private func viewRect(for box: CGRect, in size: CGSize) -> CGRect {
        CGRect(
            x: box.minX * size.width,
            y: (1 - box.maxY) * size.height,
            width: box.width * size.width,
            height: box.height * size.height
        )
    }

    private func colour(for stamp: DetectedStamp) -> Color {
        guard let result = stamp.outcome.result else { return .stampMuted.opacity(0.7) }
        return stamp.isSelected ? .stampGold : result.confidenceColor.opacity(0.8)
    }
}

// MARK: - One Detected Stamp

private struct DetectedStampCell: View {
    let stamp: DetectedStamp
    let onToggle: () -> Void
    let onOpenDetail: (Stamp) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: stamp.crop)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(8)
                    .opacity(stamp.outcome.result == nil ? 0.45 : 1)

                if stamp.outcome.result != nil {
                    Button(action: onToggle) {
                        Image(systemName: stamp.isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundStyle(stamp.isSelected ? .black : .white, stamp.isSelected ? Color.stampGold : .black.opacity(0.35))
                    }
                    .padding(6)
                }
            }

            switch stamp.outcome {
            case .identified(let result):
                Text(result.stamp.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.text)
                    .lineLimit(2)
                HStack(spacing: 4) {
                    Circle()
                        .fill(result.confidenceColor)
                        .frame(width: 6, height: 6)
                    Text(result.confidenceLabel)
                        .font(.caption2)
                        .foregroundColor(.stampMuted)
                        .lineLimit(1)
                }
            case .failed(let reason):
                // Show WHY, not a blanket "Not recognised" — a stamp we never managed to look
                // up is not a stamp we looked up and failed to find, and telling a collector
                // their Bulgarian definitive is "not recognised" is a false claim about our
                // own coverage.
                //
                // But the connectivity reason is the SAME for every tile on the page, and the
                // header already states it in full. Repeating one truncated sentence 51 times
                // is noise that buries the stamps. Say it once up there, stay quiet down here.
                Text(reason == StampClassifier.ClassifierError.backendUnavailable.errorDescription
                     ? "Not checked" : reason)
                    .font(.caption).foregroundColor(.stampMuted)
                    .lineLimit(2)
            case .pending:
                Text("…").font(.caption).foregroundColor(.stampMuted)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let result = stamp.outcome.result { onOpenDetail(result.stamp) }
        }
    }
}

// MARK: - Sticky Add Bar

private struct AddBar: View {
    let count: Int
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            Text("Add \(count) to Collection")
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.stampGold)
                .cornerRadius(14)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }
}
