import Foundation

protocol ItemRepositoryProtocol {
    func fetchAllItems() async throws -> [Item]
    func fetchItem(id: UUID) async throws -> Item?
    func createItem(_ item: Item) async throws
    func updateItem(_ item: Item) async throws
    func deleteItem(id: UUID) async throws
}

class ItemRepository: ItemRepositoryProtocol {
    private var items: [Item] = []  // In-memory mock

    func fetchAllItems() async throws -> [Item] {
        return items
    }

    func fetchItem(id: UUID) async throws -> Item? {
        return items.first(where: { $0.id == id })
    }

    func createItem(_ item: Item) async throws {
        items.append(item)
    }

    func updateItem(_ item: Item) async throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }

    func deleteItem(id: UUID) async throws {
        items.removeAll(where: { $0.id == id })
    }
}
