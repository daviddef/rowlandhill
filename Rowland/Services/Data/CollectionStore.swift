import Foundation

// MARK: - Collection Store
//
// Local-first persistence layer for the user's stamp collection.
// Backed by UserDefaults for MVP; migrate to Core Data for production.
// Server sync via StampAPIClient.fetchCollection().

final class CollectionStore {
    private let defaults = UserDefaults.standard
    private let key = "rowland.collection.items"

    func loadAll() -> [CollectionItem] {
        guard let data = defaults.data(forKey: key),
              let items = try? JSONDecoder().decode([CollectionItem].self, from: data) else {
            return []
        }
        return items
    }

    func add(_ item: CollectionItem) {
        var items = loadAll()
        items.append(item)
        save(items)
    }

    /// Add many items in one write — a page scan can yield dozens at once, and
    /// adding them one at a time would re-encode the whole collection per stamp.
    func add(_ newItems: [CollectionItem]) {
        guard !newItems.isEmpty else { return }
        var items = loadAll()
        items.append(contentsOf: newItems)
        save(items)
    }

    /// Allocate IDs for locally-created items.
    ///
    /// `CollectionItem.id` is the server's `Int` primary key, but items added offline
    /// need an ID before the server has ever seen them. Local IDs count downward from
    /// zero so they cannot collide with server-assigned positive IDs, and are replaced
    /// on first sync.
    func nextLocalIDs(count: Int) -> [Int] {
        let lowest = loadAll().map(\.id).min() ?? 0
        let start = Swift.min(lowest, 0)
        return (1...Swift.max(count, 1)).map { start - $0 }
    }

    func remove(_ item: CollectionItem) {
        var items = loadAll()
        items.removeAll { $0.id == item.id }
        save(items)
    }

    func sync(_ serverItems: [CollectionItem]) {
        // Server is source of truth — replace local copy
        save(serverItems)
    }

    private func save(_ items: [CollectionItem]) {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
    }
}

// TODO: Replace UserDefaults with Core Data for production
// Core Data schema mirrors CollectionItem + Stamp (denormalized for offline performance)
// iCloud sync via NSPersistentCloudKitContainer (Pro tier only)
