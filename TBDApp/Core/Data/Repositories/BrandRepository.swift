import Foundation
import GRDB

protocol BrandRepositoryProtocol {
    func fetchAllBrands() async throws -> [Brand]
    func createBrand(_ brand: Brand) async throws
    func deleteBrand(id: UUID) async throws
}

class BrandRepository: BrandRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    func fetchAllBrands() async throws -> [Brand] {
        try await dbManager.reader.read { db in
            try Brand.all().order(Column(SchemaDefinitions.BrandTable.name).asc).fetchAll(db)
        }
    }

    func createBrand(_ brand: Brand) async throws {
        try await dbManager.dbWriter.write { db in
            try brand.insert(db)
        }
    }

    func deleteBrand(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try Brand.deleteOne(db, key: id)
        }
    }
}
