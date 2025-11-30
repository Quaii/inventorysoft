import Foundation
import GRDB

enum ItemSortOption {
    case byDateAddedDescending
    case byTitleAscending
    case byBrand
    case byStatus
}

protocol ItemRepositoryProtocol {
    func fetchAllItems(search: String?, statusFilter: [ItemStatus]?, sort: ItemSortOption)
        async throws -> [Item]
    func fetchItem(id: UUID) async throws -> Item?
    func createItem(_ item: Item) async throws
    func updateItem(_ item: Item) async throws
    func deleteItem(id: UUID) async throws
}

class ItemRepository: ItemRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    func fetchAllItems(
        search: String? = nil, statusFilter: [ItemStatus]? = nil,
        sort: ItemSortOption = .byDateAddedDescending
    ) async throws -> [Item] {
        try await dbManager.reader.read { db in
            var request = Item.all()

            if let search = search, !search.isEmpty {
                request = request.filter(
                    Column(SchemaDefinitions.ItemTable.title).like("%\(search)%")
                        || Column(SchemaDefinitions.ItemTable.sku).like("%\(search)%"))
            }

            if let statusFilter = statusFilter, !statusFilter.isEmpty {
                request = request.filter(
                    statusFilter.map { $0.rawValue }.contains(
                        Column(SchemaDefinitions.ItemTable.status)))
            }

            switch sort {
            case .byDateAddedDescending:
                request = request.order(Column(SchemaDefinitions.ItemTable.dateAdded).desc)
            case .byTitleAscending:
                request = request.order(Column(SchemaDefinitions.ItemTable.title).asc)
            case .byBrand:
                // Join with Brand table if needed, or just sort by brandId for now (simplified)
                request = request.order(Column(SchemaDefinitions.ItemTable.brandId).asc)
            case .byStatus:
                request = request.order(Column(SchemaDefinitions.ItemTable.status).asc)
            }

            return try request.fetchAll(db)
        }
    }

    func fetchItem(id: UUID) async throws -> Item? {
        try await dbManager.reader.read { db in
            try Item.fetchOne(db, key: id)
        }
    }

    func createItem(_ item: Item) async throws {
        try await dbManager.dbWriter.write { db in
            try item.insert(db)
        }
    }

    func updateItem(_ item: Item) async throws {
        try await dbManager.dbWriter.write { db in
            try item.update(db)
        }
    }

    func deleteItem(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try Item.deleteOne(db, key: id)
        }
    }
}
