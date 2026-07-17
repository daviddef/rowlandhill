import SwiftUI
import Combine

// MARK: - App State (single source of truth)

@MainActor
final class AppState: ObservableObject {
    // Auth
    @Published var isSignedIn: Bool = false
    @Published var subscription: SubscriptionTier = .free
    @Published var userId: String? = nil

    // Navigation
    @Published var deepLinkedStampID: String? = nil
    @Published var selectedTab: Int = 0

    // Services (injected)
    let api: StampAPIClient
    let classifier: StampClassifier
    let collectionStore: CollectionStore

    init() {
        self.api = StampAPIClient()
        self.classifier = StampClassifier()
        self.collectionStore = CollectionStore()
    }

    func handleDeepLink(_ url: URL) {
        // Handle rowlandhill.app/s/SID-GB-1840-0001
        guard url.host == "rowlandhill.app",
              url.pathComponents.count >= 3,
              url.pathComponents[1] == "s" else { return }
        let stampID = url.pathComponents[2]
        deepLinkedStampID = stampID
        selectedTab = 1 // Navigate to catalogue
    }

    func signIn(appleToken: String) async {
        // TODO: POST /v1/auth/apple with the token
        // On success, store userId + subscription tier
    }
}

// MARK: - Subscription Tiers

enum SubscriptionTier: String, Codable {
    case free        // 10 scans/day, no valuations
    case pro         // $4.99/mo — unlimited scans, valuations, collection sync
    case dealerPro   // $29.99/mo — bulk tools, CSV export, marketplace listing

    var canViewValuations: Bool { self != .free }
    var scanLimitPerDay: Int? { self == .free ? 10 : nil }
    var canExportCSV: Bool { self == .dealerPro }
}

// MARK: - Design Tokens

extension Color {
    static let stampGold    = Color(red: 0.94, green: 0.65, blue: 0.0)
    static let stampSurface = Color(red: 0.086, green: 0.106, blue: 0.141)
    static let stampCard    = Color(red: 0.094, green: 0.118, blue: 0.153)
    static let stampBorder  = Color(red: 0.188, green: 0.212, blue: 0.239)
    static let stampMuted   = Color(red: 0.545, green: 0.58, blue: 0.62)

    /// Primary text colour. The app is dark-mode only in v1, so this is a
    /// fixed white rather than a semantic colour that would flip in light mode.
    static let text         = Color.white
}
