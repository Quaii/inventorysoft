import Foundation

protocol PurchaseRepositoryProtocol {
    func fetchAllPurchases() async throws -> [Purchase]
    func createPurchase(_ purchase: Purchase) async throws
}

class PurchaseRepository: PurchaseRepositoryProtocol {
    private var purchases: [Purchase] = []

    func fetchAllPurchases() async throws -> [Purchase] {
        return purchases
    }

    func createPurchase(_ purchase: Purchase) async throws {
        purchases.append(purchase)
    }
}
