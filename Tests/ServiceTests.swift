import XCTest

@testable import TBDApp

// Mock Analytics Service
class MockAnalyticsService: AnalyticsServiceProtocol {
    var inventoryValue: Decimal = 1000.0
    var itemCountValue: Int = 50
    var salesRevenue: Decimal = 500.0
    var netProfit: Decimal = 200.0

    func totalInventoryValue() async throws -> Decimal { return inventoryValue }
    func totalSalesRevenue() async throws -> Decimal { return salesRevenue }
    func totalNetProfit() async throws -> Decimal { return netProfit }
    func itemCount() async throws -> Int { return itemCountValue }
    func saleCount() async throws -> Int { return 10 }
    func getRecentActivity() async throws -> [ActivityItem] { return [] }
    func getLowStockItems() async throws -> [StockAlert] { return [] }
    func getSalesChartData() async throws -> [SalesDataPoint] { return [] }
    func itemsAddedLast24Hours() async throws -> Int { return 0 }
    func itemCountHistory(days: Int) async throws -> [ItemCountDataPoint] { return [] }
    func recentItems(limit: Int) async throws -> [RecentItemInfo] { return [] }
}

final class ServiceTests: XCTestCase {
    var mockAnalyticsService: MockAnalyticsService!
    var kpiService: KPIService!
        kpiService = KPIService(analyticsService: mockAnalyticsService)
    }

    // MARK: - KPIService Tests

    func testCalculateKPIs() async throws {
        let kpis = try await kpiService.calculateKPIs()

        XCTAssertEqual(kpis.count, 6)

        // Verify Inventory Value
        let inventoryKPI = kpis.first(where: { $0.metricKey == .inventoryValue })
        XCTAssertNotNil(inventoryKPI)
        XCTAssertTrue(inventoryKPI?.value.contains("1,000") ?? false)

        // Verify Items in Stock
        let stockKPI = kpis.first(where: { $0.metricKey == .itemsInStock })
        XCTAssertNotNil(stockKPI)
        XCTAssertEqual(stockKPI?.value, "50")
    }

    // MARK: - AlertService Tests
    // Removed as per system audit
}
