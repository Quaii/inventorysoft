import Combine
import Foundation

class DashboardViewModel: ObservableObject {
    @Published var totalInventoryValue: Decimal = 0
    @Published var totalSalesRevenue: Decimal = 0
    @Published var totalNetProfit: Decimal = 0
    @Published var itemCount: Int = 0
    @Published var saleCount: Int = 0
    @Published var recentActivity: [ActivityItem] = []
    @Published var stockAlerts: [Item] = []
    @Published var salesChartData: [SalesDataPoint] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let analyticsService: AnalyticsServiceProtocol

    init(analyticsService: AnalyticsServiceProtocol) {
        self.analyticsService = analyticsService
    }

    @MainActor
    func loadMetrics() async {
        isLoading = true
        errorMessage = nil

        do {
            // Run in parallel
            async let inventoryValue = analyticsService.totalInventoryValue()
            async let salesRevenue = analyticsService.totalSalesRevenue()
            async let netProfit = analyticsService.totalNetProfit()
            async let items = analyticsService.itemCount()
            async let sales = analyticsService.saleCount()
            async let activity = analyticsService.getRecentActivity()
            async let alerts = analyticsService.getLowStockItems()
            async let chartData = analyticsService.getSalesChartData()

            let (v, r, p, i, s, act, alt, chart) = try await (
                inventoryValue, salesRevenue, netProfit, items, sales, activity, alerts, chartData
            )

            self.totalInventoryValue = v
            self.totalSalesRevenue = r
            self.totalNetProfit = p
            self.itemCount = i
            self.saleCount = s
            self.recentActivity = act
            self.stockAlerts = alt
            self.salesChartData = chart

        } catch {
            self.errorMessage = "Failed to load dashboard metrics: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
