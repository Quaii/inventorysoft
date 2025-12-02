import Foundation
import GRDB

public protocol CategoryRepositoryProtocol {
    func fetchAllCategories() async throws -> [Category]
    func createCategory(name: String, colorHex: String?) async throws -> Category
    func deleteCategory(id: UUID) async throws
}

public class CategoryRepository: CategoryRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    public func fetchAllCategories() async throws -> [Category] {
        try await dbManager.reader.read { db in
            try Category.all().order(Column(SchemaDefinitions.CategoryTable.name).asc).fetchAll(db)
        }
    }

    public func createCategory(name: String, colorHex: String?) async throws -> Category {
        try await dbManager.dbWriter.write { db in
            var category = Category(id: UUID(), name: name, colorHex: colorHex)
            try category.insert(db)
            return category
        }
    }

    public func deleteCategory(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try Category.deleteOne(db, key: id)
        }
    }
}
