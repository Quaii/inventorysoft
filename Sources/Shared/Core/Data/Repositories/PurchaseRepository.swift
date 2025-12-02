import Foundation
import GRDB

public protocol PurchaseRepositoryProtocol {
    func fetchAllPurchases() async throws -> [Purchase]
    func createPurchase(_ purchase: Purchase) async throws
    func updatePurchase(_ purchase: Purchase) async throws
    func deletePurchase(id: UUID) async throws
}

public class PurchaseRepository: PurchaseRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    public func fetchAllPurchases() async throws -> [Purchase] {
        try await dbManager.reader.read { db in
            try Purchase.all().order(Column(SchemaDefinitions.PurchaseTable.datePurchased).desc)
                .fetchAll(db)
        }
    }

    public func createPurchase(_ purchase: Purchase) async throws {
        try await dbManager.dbWriter.write { db in
            try purchase.insert(db)
        }
    }

    public func updatePurchase(_ purchase: Purchase) async throws {
        try await dbManager.dbWriter.write { db in
            try purchase.update(db)
        }
    }

    public func deletePurchase(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try Purchase.deleteOne(db, key: id)
        }
    }
}
