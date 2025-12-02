import Foundation
import GRDB

public protocol BrandRepositoryProtocol {
    func fetchAllBrands() async throws -> [Brand]
    func createBrand(_ brand: Brand) async throws
    func deleteBrand(id: UUID) async throws
}

public class BrandRepository: BrandRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    public func fetchAllBrands() async throws -> [Brand] {
        try await dbManager.reader.read { db in
            try Brand.all().order(Column(SchemaDefinitions.BrandTable.name).asc).fetchAll(db)
        }
    }

    public func createBrand(_ brand: Brand) async throws {
        try await dbManager.dbWriter.write { db in
            try brand.insert(db)
        }
    }

    public func deleteBrand(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try Brand.deleteOne(db, key: id)
        }
    }
}
