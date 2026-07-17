import SwiftUI

// MARK: - Collection View
// User's personal stamp inventory. Syncs via iCloud for Pro users.
// Local-first (Core Data) with server sync.

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty && !viewModel.isLoading {
                    EmptyCollectionView()
                } else {
                    List(viewModel.items) { item in
                        NavigationLink(destination: StampDetailView(stamp: item.stamp)) {
                            CollectionItemRow(item: item)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Remove", role: .destructive) {
                                viewModel.remove(item)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { await viewModel.refresh() }
                }
            }
            .background(Color.stampSurface)
            .navigationTitle("My Collection")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Sort by Date Added", systemImage: "calendar") {
                            viewModel.sortBy = .dateAdded
                        }
                        Button("Sort by Country", systemImage: "flag") {
                            viewModel.sortBy = .country
                        }
                        Button("Sort by Value", systemImage: "tag") {
                            viewModel.sortBy = .value
                        }
                        Divider()
                        if appState.subscription == .dealerPro {
                            Button("Export CSV", systemImage: "square.and.arrow.up") {
                                viewModel.exportCSV()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundColor(.stampGold)
                    }
                }
            }
            .task { await viewModel.load() }
        }
    }
}

// MARK: - Collection Item Row

private struct CollectionItemRow: View {
    let item: CollectionItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: item.stamp.thumbnailURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.stampCard
            }
            .frame(width: 52, height: 64)
            .cornerRadius(5)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(item.stamp.displayName)
                    .font(.subheadline).fontWeight(.medium)
                    .lineLimit(2)
                Text(item.stamp.issuer.name)
                    .font(.caption).foregroundColor(.stampMuted)
                HStack(spacing: 8) {
                    Text(item.condition.displayName)
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.stampGold.opacity(0.15))
                        .foregroundColor(.stampGold)
                        .cornerRadius(4)
                    if item.isUsed {
                        Text("Used")
                            .font(.system(size: 10))
                            .foregroundColor(.stampMuted)
                    }
                }
            }

            Spacer()

            if let price = item.stamp.valuation?.mintTypical {
                Text("$\(Int(price))")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(.stampGold)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct EmptyCollectionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 56)).foregroundColor(.stampMuted)
            Text("Your collection is empty")
                .font(.title3).fontWeight(.semibold)
            Text("Scan a stamp or search the catalogue\nto start building your collection.")
                .font(.subheadline).foregroundColor(.stampMuted)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - ViewModel

@MainActor
final class CollectionViewModel: ObservableObject {
    @Published var items: [CollectionItem] = []
    @Published var isLoading = false
    @Published var sortBy: SortOption = .dateAdded

    enum SortOption { case dateAdded, country, value }

    private let api = StampAPIClient()
    private let store = CollectionStore()

    func load() async {
        isLoading = true
        defer { isLoading = false }
        // Load from local store first, then sync from server
        items = store.loadAll()
        if let serverItems = try? await api.fetchCollection() {
            store.sync(serverItems)
            items = store.loadAll()
        }
    }

    func refresh() async { await load() }

    func remove(_ item: CollectionItem) {
        items.removeAll { $0.id == item.id }
        store.remove(item)
        Task { try? await api.removeFromCollection(itemId: item.id) }
    }

    func exportCSV() {
        // TODO: Generate CSV and present share sheet
        // Available for DealerPro tier only
    }
}

// MARK: - Marketplace placeholder

struct MarketplaceView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "storefront").font(.system(size: 56)).foregroundColor(.stampMuted)
                Text("Marketplace").font(.title2).fontWeight(.bold)
                Text("Buy and sell stamps with other collectors.\nComing in Phase 4.")
                    .font(.subheadline).foregroundColor(.stampMuted)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .background(Color.stampSurface)
            .navigationTitle("Market")
        }
    }
}
