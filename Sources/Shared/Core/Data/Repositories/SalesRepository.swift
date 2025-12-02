import Foundation
import GRDB

public protocol SalesRepositoryProtocol {
    func fetchAllSales() async throws -> [Sale]
    func fetchSales(forItemId id: UUID) async throws -> [Sale]
    func createSale(_ sale: Sale) async throws
    func updateSale(_ sale: Sale) async throws
    func deleteSale(id: UUID) async throws
}

public class SalesRepository: SalesRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    public init() {}

    public func fetchAllSales() async throws -> [Sale] {
        try await dbManager.reader.read { db in
            try Sale.all().order(Column(SchemaDefinitions.SaleTable.dateSold).desc).fetchAll(db)
        }
    }

    public func fetchSales(forItemId id: UUID) async throws -> [Sale] {
        try await dbManager.reader.read { db in
            try Sale.filter(Column(SchemaDefinitions.SaleTable.itemId) == id).fetchAll(db)
        }
    }

    public func createSale(_ sale: Sale) async throws {
        try await dbManager.dbWriter.write { db in
            try sale.insert(db)
        }
    }

    public func updateSale(_ sale: Sale) async throws {
        try await dbManager.dbWriter.write { db in
            try sale.update(db)
        }
    }

    public func deleteSale(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try Sale.deleteOne(db, key: id)
        }
    }
}
