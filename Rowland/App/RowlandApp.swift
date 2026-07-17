import SwiftUI

@main
struct RowlandApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root Tab View

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .scan

    enum Tab: String, CaseIterable {
        case scan       = "Scan"
        case catalogue  = "Catalogue"
        case collection = "Collection"
        case market     = "Market"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ScanView()
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
                .tag(Tab.scan)

            CatalogueView()
                .tabItem { Label("Catalogue", systemImage: "books.vertical") }
                .tag(Tab.catalogue)

            CollectionView()
                .tabItem { Label("Collection", systemImage: "square.grid.2x2") }
                .tag(Tab.collection)

            MarketplaceView()
                .tabItem { Label("Market", systemImage: "storefront") }
                .tag(Tab.market)
        }
        .tint(.stampGold)
        .onOpenURL { url in
            // Universal Links: rowlandhill.app/s/SID-GB-1840-0001
            appState.handleDeepLink(url)
        }
    }
}
