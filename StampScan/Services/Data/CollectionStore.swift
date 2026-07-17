import Foundation

// MARK: - Collection Store
//
// Local-first persistence layer for the user's stamp collection.
// Backed by UserDefaults for MVP; migrate to Core Data for production.
// Server sync via StampAPIClient.fetchCollection().

final class CollectionStore {
    private let defaults = UserDefaults.standard
    private let key = "stampscan.collection.items"

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
