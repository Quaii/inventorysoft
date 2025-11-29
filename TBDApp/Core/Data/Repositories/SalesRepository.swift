import Foundation

protocol SalesRepositoryProtocol {
    func fetchAllSales() async throws -> [Sale]
    func createSale(_ sale: Sale) async throws
}

class SalesRepository: SalesRepositoryProtocol {
    private var sales: [Sale] = []

    func fetchAllSales() async throws -> [Sale] {
        return sales
    }

    func createSale(_ sale: Sale) async throws {
        sales.append(sale)
    }
}
