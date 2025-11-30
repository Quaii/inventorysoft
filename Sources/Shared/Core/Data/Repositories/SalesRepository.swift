import Foundation
import GRDB

protocol SalesRepositoryProtocol {
    func fetchAllSales() async throws -> [Sale]
    func fetchSales(forItemId id: UUID) async throws -> [Sale]
    func createSale(_ sale: Sale) async throws
    func updateSale(_ sale: Sale) async throws
    func deleteSale(id: UUID) async throws
}

class SalesRepository: SalesRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    func fetchAllSales() async throws -> [Sale] {
        try await dbManager.reader.read { db in
            try Sale.all().order(Column(SchemaDefinitions.SaleTable.dateSold).desc).fetchAll(db)
        }
    }

    func fetchSales(forItemId id: UUID) async throws -> [Sale] {
        try await dbManager.reader.read { db in
            try Sale.filter(Column(SchemaDefinitions.SaleTable.itemId) == id).fetchAll(db)
        }
    }

    func createSale(_ sale: Sale) async throws {
        try await dbManager.dbWriter.write { db in
            try sale.insert(db)
        }
    }

    func updateSale(_ sale: Sale) async throws {
        try await dbManager.dbWriter.write { db in
            try sale.update(db)
        }
    }

    func deleteSale(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try Sale.deleteOne(db, key: id)
        }
    }
}
