import SwiftUI

// MARK: - Stamp Detail View
//
// Full detail screen for a single stamp.
// Accessible from: ScanResultView, CatalogueView, CollectionView, deep links (rowlandhill.app/s/SID-...)

struct StampDetailView: View {
    let stamp: Stamp
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: StampDetailViewModel
    @State private var showShareSheet = false
    @State private var showAddToCollection = false
    @State private var selectedImageIndex = 0

    init(stamp: Stamp) {
        self.stamp = stamp
        _viewModel = StateObject(wrappedValue: StampDetailViewModel(stamp: stamp))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Image carousel
                ImageCarousel(stamp: stamp, selectedIndex: $selectedImageIndex)

                // Core info section
                VStack(alignment: .leading, spacing: 20) {
                    StampHeaderSection(stamp: stamp)
                    Divider().background(Color.stampBorder)
                    if let description = stamp.description {
                        DescriptionSection(description: description)
                        Divider().background(Color.stampBorder)
                    }
                    PhysicalDetailsSection(stamp: stamp)
                    if !stamp.catalogueRefs.isEmpty {
                        Divider().background(Color.stampBorder)
                        CatalogueNumbersSection(refs: stamp.catalogueRefs)
                    }
                    Divider().background(Color.stampBorder)
                    ValuationSection(stamp: stamp, subscription: appState.subscription)
                    if !stamp.topics.isEmpty {
                        Divider().background(Color.stampBorder)
                        TopicsSection(topics: stamp.topics)
                    }
                    Divider().background(Color.stampBorder)
                    DataProvenanceSection(stamp: stamp)
                }
                .padding(20)
            }
        }
        .background(Color.stampSurface)
        .navigationTitle(stamp.stampID)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add to Collection", systemImage: "plus.circle") {
                        showAddToCollection = true
                    }
                    Button("Share", systemImage: "square.and.arrow.up") {
                        showShareSheet = true
                    }
                    Button("Copy StampID", systemImage: "doc.on.clipboard") {
                        UIPasteboard.general.string = stamp.stampID
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.stampGold)
                }
            }
        }
        .sheet(isPresented: $showAddToCollection) {
            AddToCollectionSheet(stamp: stamp, onAdd: { showAddToCollection = false })
                .environmentObject(appState)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [
                "Check out this stamp on Rowland: https://rowlandhill.app/s/\(stamp.stampID)"
            ])
        }
    }
}

// MARK: - Section Components

private struct ImageCarousel: View {
    let stamp: Stamp
    @Binding var selectedIndex: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)

            AsyncImage(url: stamp.primaryImageURL) { image in
                image.resizable().aspectRatio(contentMode: .fit)
                    .padding(24)
            } placeholder: {
                VStack(spacing: 12) {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundColor(.stampMuted)
                    Text("No image available")
                        .font(.caption).foregroundColor(.stampMuted)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
    }
}

private struct StampHeaderSection: View {
    let stamp: Stamp

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stamp.format.displayName.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.stampGold)
                Spacer()
                Text(stamp.sourceTier.badge)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.stampMuted)
            }
            Text(stamp.displayName)
                .font(.title2).fontWeight(.bold)

            HStack(spacing: 16) {
                Label(stamp.issuer.name, systemImage: "flag.fill")
                Label(stamp.formattedDate, systemImage: "calendar")
                Label(stamp.formattedDenomination, systemImage: "tag.fill")
            }
            .font(.caption)
            .foregroundColor(.stampMuted)
        }
    }
}

private struct DescriptionSection: View {
    let description: String
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About this stamp")
                .font(.subheadline).fontWeight(.semibold)
            Text(description)
                .font(.body)
                .foregroundColor(.stampMuted)
                .lineLimit(expanded ? nil : 4)
            if description.count > 200 {
                Button(expanded ? "Show less" : "Read more") {
                    withAnimation { expanded.toggle() }
                }
                .font(.caption).foregroundColor(.stampGold)
            }
        }
    }
}

private struct PhysicalDetailsSection: View {
    let stamp: Stamp

    private var rows: [(String, String)] {
        var result: [(String, String)] = []
        if let pm = stamp.printMethod    { result.append(("Print Method", pm.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)) }
        if let pt = stamp.perforationType { result.append(("Perforation", pt.rawValue.capitalized)) }
        if let gh = stamp.perfGaugeH     {
            let perf = stamp.perfGaugeV.map { gh == $0 ? "\(gh)" : "\(gh) × \($0)" } ?? "\(gh)"
            result.append(("Perf Gauge", perf))
        }
        if let wm = stamp.watermark      { result.append(("Watermark", wm)) }
        if let pt = stamp.paperType      { result.append(("Paper", pt)) }
        if !stamp.colour.isEmpty         { result.append(("Colour", stamp.colour.joined(separator: ", ").capitalized)) }
        if let d = stamp.designer        { result.append(("Designer", d)) }
        if let e = stamp.engraver        { result.append(("Engraver", e)) }
        if let p = stamp.printer         { result.append(("Printer", p)) }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Physical Details")
                .font(.subheadline).fontWeight(.semibold)
            ForEach(rows, id: \.0) { label, value in
                HStack {
                    Text(label)
                        .font(.caption).foregroundColor(.stampMuted)
                    Spacer()
                    Text(value)
                        .font(.caption).fontWeight(.medium)
                }
            }
        }
    }
}

private struct CatalogueNumbersSection: View {
    let refs: [CatalogueRef]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Catalogue Numbers")
                .font(.subheadline).fontWeight(.semibold)
            ForEach(refs) { ref in
                HStack {
                    Text(ref.catalogueName)
                        .font(.caption).foregroundColor(.stampMuted)
                        .frame(width: 120, alignment: .leading)
                    Text(ref.number)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.stampGold)
                    Spacer()
                    if ref.confirmed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .font(.caption)
                            .foregroundColor(.stampMuted)
                    }
                }
            }
        }
    }
}

private struct ValuationSection: View {
    let stamp: Stamp
    let subscription: SubscriptionTier

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Market Value")
                .font(.subheadline).fontWeight(.semibold)

            if subscription == .free {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill").foregroundColor(.stampGold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Unlock with Rowland Pro")
                            .font(.subheadline).fontWeight(.medium)
                        Text("$4.99/month · Cancel anytime")
                            .font(.caption).foregroundColor(.stampMuted)
                    }
                    Spacer()
                    Button("Upgrade") {
                        // TODO: Present paywall
                    }
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.stampGold)
                    .cornerRadius(8)
                }
                .padding(14)
                .background(Color.stampGold.opacity(0.06))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.stampGold.opacity(0.3)))
            } else if let v = stamp.valuation {
                HStack {
                    ValuationTile(label: "Mint", price: v.mintDisplayPrice, range: v.mintMin.map { "(\(Int($0))–\(Int(v.mintMax ?? 0)))" })
                    Divider().frame(height: 40).background(Color.stampBorder)
                    ValuationTile(label: "Used", price: v.usedDisplayPrice, range: v.usedMin.map { "(\(Int($0))–\(Int(v.usedMax ?? 0)))" })
                }
                Text("Based on \(v.sourceType == "auction_realised" ? "recent auction results" : "catalogue values") · \(v.asOf ?? "recent")")
                    .font(.system(size: 10))
                    .foregroundColor(.stampMuted)
            } else {
                Text("No valuation data available")
                    .font(.caption).foregroundColor(.stampMuted)
            }
        }
    }
}

private struct ValuationTile: View {
    let label: String
    let price: String
    let range: String?

    var body: some View {
        VStack(spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.stampMuted)
            Text(price)
                .font(.title3).fontWeight(.bold).foregroundColor(.stampGold)
            if let r = range {
                Text(r).font(.system(size: 10)).foregroundColor(.stampMuted)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TopicsSection: View {
    let topics: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Themes")
                .font(.subheadline).fontWeight(.semibold)
            FlowLayout(spacing: 6) {
                ForEach(topics, id: \.self) { topic in
                    Text(topic.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.stampGold.opacity(0.1))
                        .foregroundColor(.stampGold)
                        .cornerRadius(20)
                }
            }
        }
    }
}

private struct DataProvenanceSection: View {
    let stamp: Stamp

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Data Source")
                .font(.subheadline).fontWeight(.semibold)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(stamp.sourceTier.badge)
                        .font(.caption).fontWeight(.semibold).foregroundColor(.stampGold)
                    Text("Confidence: \(Int(stamp.confidence * 100))%")
                        .font(.caption).foregroundColor(.stampMuted)
                }
                Spacer()
                Text(stamp.stampID)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.stampMuted.opacity(0.6))
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class StampDetailViewModel: ObservableObject {
    @Published var stamp: Stamp
    @Published var isLoadingDetail = false

    private let api = StampAPIClient()

    init(stamp: Stamp) {
        self.stamp = stamp
        Task { await loadFullDetail() }
    }

    func loadFullDetail() async {
        isLoadingDetail = true
        defer { isLoadingDetail = false }
        if let fullStamp = try? await api.fetchStamp(id: stamp.stampID) {
            stamp = fullStamp
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
