import Foundation
import GRDB

public enum ItemSortOption {
    case byDateAddedDescending
    case byTitleAscending
    case byBrand
    case byStatus
}

public protocol ItemRepositoryProtocol {
    func fetchAllItems(search: String?, statusFilter: [ItemStatus]?, sort: ItemSortOption)
        async throws -> [Item]
    func fetchItem(id: UUID) async throws -> Item?
    func createItem(_ item: Item) async throws
    func updateItem(_ item: Item) async throws
    func deleteItem(id: UUID) async throws
}

public class ItemRepository: ItemRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    public init() {}

    public func fetchAllItems(
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

            var items = try request.fetchAll(db)

            // Populate images for each item
            // Note: In a real app with many items, this N+1 query should be optimized with a join or batch fetch.
            // For now, we'll fetch all images and map them in memory for simplicity/speed given local DB.
            let allImages = try ImageAttachment.fetchAll(db)
            let imageMap = Dictionary(grouping: allImages, by: { $0.itemId })

            for i in 0..<items.count {
                if let itemImages = imageMap[items[i].id] {
                    items[i].images = itemImages
                }
            }

            return items
        }
    }

    public func fetchItem(id: UUID) async throws -> Item? {
        try await dbManager.reader.read { db in
            try Item.fetchOne(db, key: id)
        }
    }

    public func createItem(_ item: Item) async throws {
        try await dbManager.dbWriter.write { db in
            try item.insert(db)
        }
    }

    public func updateItem(_ item: Item) async throws {
        try await dbManager.dbWriter.write { db in
            try item.update(db)
        }
    }

    public func deleteItem(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try Item.deleteOne(db, key: id)
        }
    }
}
