import Foundation

protocol AnalyticsServiceProtocol {
    func totalInventoryValue() async throws -> Decimal
    func totalSalesRevenue() async throws -> Decimal
    func totalNetProfit() async throws -> Decimal
    func itemCount() async throws -> Int
    func saleCount() async throws -> Int
}

class AnalyticsService: AnalyticsServiceProtocol {
    private let itemRepository: ItemRepositoryProtocol
    private let salesRepository: SalesRepositoryProtocol

    init(itemRepository: ItemRepositoryProtocol, salesRepository: SalesRepositoryProtocol) {
        self.itemRepository = itemRepository
        self.salesRepository = salesRepository
    }

    func totalInventoryValue() async throws -> Decimal {
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: [.inStock, .listed], sort: .byDateAddedDescending)
        return items.reduce(0) { $0 + ($1.purchasePrice * Decimal($1.quantity)) }
    }

    func totalSalesRevenue() async throws -> Decimal {
        let sales = try await salesRepository.fetchAllSales()
        return sales.reduce(0) { $0 + $1.soldPrice }
    }

    func totalNetProfit() async throws -> Decimal {
        let sales = try await salesRepository.fetchAllSales()
        var totalProfit: Decimal = 0

        for sale in sales {
            // Fetch the item to get its purchase price
            // Note: This assumes 1 sale = 1 item unit. If quantity > 1, logic needs adjustment.
            // For Phase 2, we assume simple 1-to-1 or that purchasePrice is per unit.
            if let item = try await itemRepository.fetchItem(id: sale.itemId) {
                let cost = item.purchasePrice  // Cost of Goods Sold
                let revenue = sale.soldPrice
                let fees = sale.fees
                let profit = revenue - fees - cost
                totalProfit += profit
            }
        }

        return totalProfit
    }

    func itemCount() async throws -> Int {
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: nil, sort: .byDateAddedDescending)
        return items.count
    }

    func saleCount() async throws -> Int {
        let sales = try await salesRepository.fetchAllSales()
        return sales.count
    }
}
