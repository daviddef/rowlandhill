import SwiftUI

// MARK: - Catalogue View
//
// Browse and search the full stamp database.
// Filters: country, year range, topic, format, catalogue system + number
// Results use server-side Elasticsearch for full-text + faceted search

struct CatalogueView: View {
    @StateObject private var viewModel = CatalogueViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $viewModel.query, onSubmit: { viewModel.search() })
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                // Active filter chips
                if !viewModel.activeFilters.isEmpty {
                    ActiveFilterChips(filters: viewModel.activeFilters, onRemove: viewModel.removeFilter)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }

                // Results
                if viewModel.isLoading && viewModel.stamps.isEmpty {
                    Spacer()
                    ProgressView().tint(.stampGold)
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage, viewModel.stamps.isEmpty {
                    SearchErrorView(message: errorMessage) { viewModel.retry() }
                } else if viewModel.stamps.isEmpty && !viewModel.query.isEmpty {
                    EmptyResultsView(query: viewModel.query)
                } else {
                    StampGrid(
                        stamps: viewModel.stamps,
                        hasMore: viewModel.hasMore,
                        onLoadMore: viewModel.loadNextPage
                    )
                }
            }
            .background(Color.stampSurface)
            .navigationTitle("Catalogue")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showFilters = true
                    } label: {
                        Image(systemName: viewModel.activeFilters.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                            .foregroundColor(.stampGold)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showFilters) {
                FilterSheet(viewModel: viewModel)
            }
            .onAppear {
                if viewModel.stamps.isEmpty {
                    viewModel.loadFeatured()
                }
            }
        }
    }
}

// MARK: - Stamp Grid

private struct StampGrid: View {
    let stamps: [Stamp]
    let hasMore: Bool
    let onLoadMore: () -> Void

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(stamps) { stamp in
                    NavigationLink(destination: StampDetailView(stamp: stamp)) {
                        StampThumbnailCard(stamp: stamp)
                    }
                }
                if hasMore {
                    Color.clear
                        .onAppear { onLoadMore() }
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Stamp Thumbnail Card (grid item)

struct StampThumbnailCard: View {
    let stamp: Stamp

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: stamp.thumbnailURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.stampCard
                    .overlay(Image(systemName: "photo").foregroundColor(.stampMuted))
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(0.85, contentMode: .fit)
            .cornerRadius(6)
            .clipped()

            Text(stamp.displayName)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(2)
                .foregroundColor(.text)

            Text(stamp.formattedDate)
                .font(.system(size: 10))
                .foregroundColor(.stampMuted)
        }
        .padding(8)
        .background(Color.stampCard)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.stampBorder))
    }
}

// MARK: - Supporting Views

private struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.stampMuted)
            TextField("Search stamps, countries, topics...", text: $text)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .foregroundColor(.text)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.stampMuted)
                }
            }
        }
        .padding(10)
        .background(Color.stampCard)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(isFocused ? Color.stampGold.opacity(0.6) : Color.stampBorder))
    }
}

private struct ActiveFilterChips: View {
    let filters: [SearchFilter]
    let onRemove: (SearchFilter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.label) { filter in
                    HStack(spacing: 4) {
                        Text(filter.label)
                            .font(.caption).fontWeight(.medium)
                        Button { onRemove(filter) } label: {
                            Image(systemName: "xmark").font(.system(size: 9, weight: .bold))
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.stampGold.opacity(0.15))
                    .foregroundColor(.stampGold)
                    .cornerRadius(20)
                }
            }
        }
    }
}

private struct SearchErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44)).foregroundColor(.orange)
            Text("Couldn't load the catalogue")
                .font(.headline).foregroundColor(.text)
            Text(message)
                .font(.subheadline).foregroundColor(.stampMuted)
                .multilineTextAlignment(.center)
            Button("Try Again", action: onRetry)
                .font(.headline).foregroundColor(.stampGold)
            Spacer()
        }
        .padding(32)
    }
}

private struct EmptyResultsView: View {
    let query: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass").font(.system(size: 48)).foregroundColor(.stampMuted)
            Text("No stamps found for “\(query)”")
                .font(.headline)
            Text("Try different search terms, or browse by country")
                .font(.subheadline).foregroundColor(.stampMuted)
            Spacer()
        }
        .padding()
    }
}

// MARK: - Filter Sheet

private struct FilterSheet: View {
    @ObservedObject var viewModel: CatalogueViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Country") {
                    // TODO: CountryPickerView — loads from /v1/meta/countries
                    TextField("e.g. Great Britain, Zimbabwe, Rhodesia", text: $viewModel.filterCountry)
                }
                Section("Year Range") {
                    HStack {
                        TextField("From", value: $viewModel.filterYearFrom, format: .number)
                            .keyboardType(.numberPad)
                        Text("–")
                        TextField("To", value: $viewModel.filterYearTo, format: .number)
                            .keyboardType(.numberPad)
                    }
                }
                Section("Topic") {
                    // TODO: Topic picker with common thematic categories
                    TextField("e.g. fauna, royalty, aviation", text: $viewModel.filterTopic)
                }
                Section("Format") {
                    Picker("Format", selection: $viewModel.filterFormat) {
                        Text("Any").tag(Optional<StampFormat>.none)
                        ForEach(StampFormat.allCases, id: \.self) { f in
                            Text(f.displayName).tag(Optional(f))
                        }
                    }
                }
                Section("Catalogue Number") {
                    HStack {
                        Picker("System", selection: $viewModel.filterCatalogue) {
                            Text("Scott").tag("scott")
                            Text("SG").tag("sg")
                            Text("Michel").tag("michel")
                            Text("Yvert").tag("yvert")
                        }
                        .pickerStyle(.menu)
                        TextField("Number", text: $viewModel.filterCatalogueNumber)
                    }
                }
            }
            .navigationTitle("Filter Stamps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") { viewModel.resetFilters() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        viewModel.search()
                        dismiss()
                    }
                    .foregroundColor(.stampGold)
                }
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class CatalogueViewModel: ObservableObject {
    @Published var stamps: [Stamp] = []
    @Published var query: String = ""
    @Published var isLoading = false
    @Published var hasMore = false
    @Published var errorMessage: String? = nil
    @Published var showFilters = false

    // Filter state
    @Published var filterCountry: String = ""
    @Published var filterYearFrom: Int? = nil
    @Published var filterYearTo: Int? = nil
    @Published var filterTopic: String = ""
    @Published var filterFormat: StampFormat? = nil
    @Published var filterCatalogue: String = "scott"
    @Published var filterCatalogueNumber: String = ""

    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    private let api = StampAPIClient()

    var activeFilters: [SearchFilter] {
        var filters: [SearchFilter] = []
        if !filterCountry.isEmpty        { filters.append(.init(key: "country", label: "Country: \(filterCountry)")) }
        if let y = filterYearFrom        { filters.append(.init(key: "year_from", label: "From \(y)")) }
        if let y = filterYearTo          { filters.append(.init(key: "year_to", label: "To \(y)")) }
        if !filterTopic.isEmpty          { filters.append(.init(key: "topic", label: filterTopic.capitalized)) }
        if let f = filterFormat          { filters.append(.init(key: "format", label: f.displayName)) }
        if !filterCatalogueNumber.isEmpty { filters.append(.init(key: "cat", label: "\(filterCatalogue.uppercased()) \(filterCatalogueNumber)")) }
        return filters
    }

    func removeFilter(_ filter: SearchFilter) {
        switch filter.key {
        case "country":   filterCountry = ""
        case "year_from": filterYearFrom = nil
        case "year_to":   filterYearTo = nil
        case "topic":     filterTopic = ""
        case "format":    filterFormat = nil
        case "cat":       filterCatalogueNumber = ""
        default: break
        }
        search()
    }

    func resetFilters() {
        filterCountry = ""; filterYearFrom = nil; filterYearTo = nil
        filterTopic = ""; filterFormat = nil; filterCatalogueNumber = ""
    }

    func search() {
        searchTask?.cancel()
        currentPage = 1
        stamps = []
        searchTask = Task { await performSearch(page: 1) }
    }

    func loadNextPage() {
        guard !isLoading, hasMore else { return }
        currentPage += 1
        searchTask = Task { await performSearch(page: currentPage) }
    }

    func retry() {
        errorMessage = nil
        searchTask = Task { await performSearch(page: currentPage) }
    }

    func loadFeatured() {
        // Load featured/trending stamps for empty state
        searchTask = Task { await performSearch(page: 1) }
    }

    private func performSearch(page: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // The bundled catalogue answers first. It holds the whole corpus as text, so browse and
        // search work with no server, no domain and no connection — which is the difference
        // between this tab working and this tab apologising. The API is for what the bundle
        // can't know: valuations, catalogue refs, and anything added since the build.
        if LocalCatalogue.shared.isAvailable && filterCatalogueNumber.isEmpty {
            let results = LocalCatalogue.shared.search(
                query: [query, filterTopic].filter { !$0.isEmpty }.joined(separator: " "),
                country: filterCountry.isEmpty ? nil : filterCountry,
                yearFrom: filterYearFrom,
                yearTo: filterYearTo,
                page: page
            )
            if page == 1 { stamps = results } else { stamps.append(contentsOf: results) }
            hasMore = results.count >= 40
            return
        }

        do {
            // If catalogue number is specified, do a direct catalogue lookup
            if !filterCatalogueNumber.isEmpty {
                let stamp = try await api.fetchStampByCatalogue(
                    catalogue: filterCatalogue,
                    number: filterCatalogueNumber
                )
                stamps = [stamp]
                hasMore = false
                return
            }

            let q = [query, filterCountry, filterTopic].filter { !$0.isEmpty }.joined(separator: " ")

            let response = try await api.search(
                query: q.isEmpty ? "*" : q,
                country: filterCountry.isEmpty ? nil : filterCountry,
                yearFrom: filterYearFrom,
                yearTo: filterYearTo,
                topic: filterTopic.isEmpty ? nil : filterTopic,
                page: page
            )
            if page == 1 { stamps = response.stamps }
            else { stamps.append(contentsOf: response.stamps) }
            hasMore = page < response.totalPages
        } catch is CancellationError {
            // Superseded by a newer query — not a failure worth showing.
        } catch {
            // A swallowed error is indistinguishable from "no results", which is how a
            // failed request used to render as an empty grid forever. Say what happened —
            // but in the user's terms. URLError's own text ("A server with the specified
            // hostname could not be found") describes our infrastructure, not their problem.
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    errorMessage = "You're offline. Check your connection and try again."
                default:
                    errorMessage = "Can't reach the catalogue right now. Try again in a moment."
                }
            } else {
                errorMessage = error.localizedDescription
            }
            hasMore = false
        }
    }
}

struct SearchFilter {
    let key: String
    let label: String
}
