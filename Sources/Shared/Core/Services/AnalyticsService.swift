import Foundation

public protocol AnalyticsServiceProtocol {
    func totalInventoryValue() async throws -> Decimal
    func totalSalesRevenue() async throws -> Decimal
    func totalNetProfit() async throws -> Decimal
    func itemCount() async throws -> Int
    func saleCount() async throws -> Int
    func itemCount(status: ItemStatus) async throws -> Int
    func saleCount(since date: Date) async throws -> Int
    func getRecentActivity() async throws -> [ActivityItem]
    func getLowStockItems() async throws -> [StockAlert]
    func getSalesChartData() async throws -> [SalesDataPoint]
    func itemsAddedLast24Hours() async throws -> Int
    func itemCountHistory(days: Int) async throws -> [ItemCountDataPoint]
    func recentItems(limit: Int) async throws -> [RecentItemInfo]
}

public class AnalyticsService: AnalyticsServiceProtocol {
    private let itemRepository: ItemRepositoryProtocol
    private let salesRepository: SalesRepositoryProtocol

    public init(itemRepository: ItemRepositoryProtocol, salesRepository: SalesRepositoryProtocol) {
        self.itemRepository = itemRepository
        self.salesRepository = salesRepository
    }

    public func totalInventoryValue() async throws -> Decimal {
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: [.inStock, .listed], sort: .byDateAddedDescending)
        return items.reduce(0) { $0 + ($1.purchasePrice * Decimal($1.quantity)) }
    }

    public func totalSalesRevenue() async throws -> Decimal {
        let sales = try await salesRepository.fetchAllSales()
        return sales.reduce(0) { $0 + $1.soldPrice }
    }

    public func totalNetProfit() async throws -> Decimal {
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

    public func itemCount() async throws -> Int {
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: nil, sort: .byDateAddedDescending)
        return items.count
    }

    public func itemCount(status: ItemStatus) async throws -> Int {
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: [status], sort: .byDateAddedDescending)
        return items.count
    }

    public func saleCount() async throws -> Int {
        let sales = try await salesRepository.fetchAllSales()
        return sales.count
    }

    public func saleCount(since date: Date) async throws -> Int {
        let sales = try await salesRepository.fetchAllSales()
        return sales.filter { $0.dateSold >= date }.count
    }

    public func getRecentActivity() async throws -> [ActivityItem] {
        // Fetch recent sales
        let sales = try await salesRepository.fetchAllSales()
        let recentSales = sales.sorted(by: { $0.dateSold > $1.dateSold }).prefix(5)

        // Fetch recent items
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: nil, sort: .byDateAddedDescending)
        let recentItems = items.prefix(5)

        var activities: [ActivityItem] = []

        for sale in recentSales {
            activities.append(
                ActivityItem(
                    id: sale.id,
                    title: "Item Sold",
                    description: "Sold for \(sale.soldPrice.formatted(.currency(code: "USD")))",
                    type: .sale,
                    date: sale.dateSold
                ))
        }

        for item in recentItems {
            activities.append(
                ActivityItem(
                    id: item.id,
                    title: "New Item Added",
                    description: item.title,
                    type: .purchase,
                    date: item.dateAdded
                ))
        }

        return activities.sorted(by: { $0.date > $1.date }).prefix(10).map { $0 }
    }

    public func getLowStockItems() async throws -> [StockAlert] {
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: [.inStock], sort: .byDateAddedDescending)
        return items.filter { $0.quantity < 3 }.map { item in
            StockAlert(
                title: item.title,
                message: "Low stock: \(item.quantity) remaining",
                severity: .low
            )
        }
    }

    public func getSalesChartData() async throws -> [SalesDataPoint] {
        let sales = try await salesRepository.fetchAllSales()
        // Group by day for the last 7 days
        let calendar = Calendar.current
        let today = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today)!

        let recentSales = sales.filter { $0.dateSold >= sevenDaysAgo }

        var dailyTotals: [Date: Decimal] = [:]

        for sale in recentSales {
            let day = calendar.startOfDay(for: sale.dateSold)
            dailyTotals[day, default: 0] += sale.soldPrice
        }

        var dataPoints: [SalesDataPoint] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let day = calendar.startOfDay(for: date)
                dataPoints.append(
                    SalesDataPoint(
                        date: day,
                        amount: Double(truncating: (dailyTotals[day] ?? 0) as NSDecimalNumber)))
            }
        }

        return dataPoints.sorted(by: { $0.date < $1.date })
    }
    public func itemsAddedLast24Hours() async throws -> Int {
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: nil, sort: .byDateAddedDescending)
        let calendar = Calendar.current
        let oneDayAgo = calendar.date(byAdding: .hour, value: -24, to: Date())!
        return items.filter { $0.dateAdded >= oneDayAgo }.count
    }

    public func itemCountHistory(days: Int) async throws -> [ItemCountDataPoint] {
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: nil, sort: .byDateAddedDescending)
        let calendar = Calendar.current
        let today = Date()
        var history: [Date: Int] = [:]

        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let day = calendar.startOfDay(for: date)
                let nextDay = calendar.date(byAdding: .day, value: 1, to: day)!

                let count = items.filter { $0.dateAdded >= day && $0.dateAdded < nextDay }.count
                history[day] = count
            }
        }
        return history.map { date, count in
            ItemCountDataPoint(date: date, count: count)
        }.sorted(by: { $0.date < $1.date })
    }

    public func recentItems(limit: Int) async throws -> [RecentItemInfo] {
        let items = try await itemRepository.fetchAllItems(
            search: nil, statusFilter: nil, sort: .byDateAddedDescending)
        return items.prefix(limit).map { item in
            RecentItemInfo(
                id: item.id,
                title: item.title,
                dateAdded: item.dateAdded,
                price: Double(truncating: item.purchasePrice as NSDecimalNumber),
                status: item.status.rawValue,
                condition: item.condition
            )
        }
    }
}
