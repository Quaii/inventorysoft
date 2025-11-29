import Foundation
import GRDB

protocol CategoryRepositoryProtocol {
    func fetchAllCategories() async throws -> [Category]
    func createCategory(_ category: Category) async throws
    func deleteCategory(id: UUID) async throws
}

class CategoryRepository: CategoryRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    func fetchAllCategories() async throws -> [Category] {
        try await dbManager.reader.read { db in
            try Category.all().order(Column(SchemaDefinitions.CategoryTable.name).asc).fetchAll(db)
        }
    }

    func createCategory(_ category: Category) async throws {
        try await dbManager.dbWriter.write { db in
            try category.insert(db)
        }
    }

    func deleteCategory(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try Category.deleteOne(db, key: id)
        }
    }
}
