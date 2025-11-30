import Combine
import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    private let analyticsService: AnalyticsServiceProtocol
    private let dashboardConfigService: DashboardConfigServiceProtocol

    @Published var widgets: [DashboardWidget] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isConfiguring = false

    // Widget data
    @Published var totalInventoryValue: Double = 0
    @Published var totalItems: Int = 0

    @Published var recentActivity: [ActivityItem] = []
    @Published var salesChartData: [SalesDataPoint] = []

    // New dashboard card properties
    @Published var itemsPerDay: Int? = nil
    @Published var stockAlerts: [StockAlert] = []
    @Published var recentItems: [RecentItemInfo] = []
    @Published var itemCountHistory: [ItemCountDataPoint] = []

    init(
        analyticsService: AnalyticsServiceProtocol,
        dashboardConfigService: DashboardConfigServiceProtocol
    ) {
        self.analyticsService = analyticsService
        self.dashboardConfigService = dashboardConfigService
    }

    func loadMetrics() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load widgets configuration
            widgets = try await dashboardConfigService.getWidgets()

            // Load data for visible widgets
            try await loadWidgetData()

            isLoading = false
        } catch {
            // Sanitize error message - never show raw SQL or stack traces
            errorMessage = sanitizeErrorMessage(error)
            isLoading = false

            // Log technical details to console
            print("Dashboard load error: \(error)")
            let technicalError = error as NSError
            print("Technical details: \(technicalError.userInfo)")
        }
    }

    func resetDashboard() async {
        isLoading = true
        errorMessage = nil

        do {
            try await dashboardConfigService.resetToDefaults()
            widgets = try await dashboardConfigService.getWidgets()
            try await loadWidgetData()
            isLoading = false
        } catch {
            errorMessage = sanitizeErrorMessage(error)
            isLoading = false
            print("Dashboard reset error: \(error)")
        }
    }

    // Sanitize errors to prevent SQL/stack traces from reaching UI
    private func sanitizeErrorMessage(_ error: Error) -> String {
        let errorString = error.localizedDescription.lowercased()

        // Check for SQL-related errors
        if errorString.contains("sql") || errorString.contains("database")
            || errorString.contains("column") || errorString.contains("table")
        {
            return "Unable to load dashboard configuration. Please check Settings."
        }

        // Check for network/connection errors
        if errorString.contains("network") || errorString.contains("connection") {
            return "Network error. Please check your connection."
        }

        // Generic fallback
        return "An error occurred while loading the dashboard."
    }

    func saveWidgetConfiguration(_ newWidgets: [DashboardWidget]) async {
        do {
            try await dashboardConfigService.saveWidgetConfiguration(newWidgets)
            widgets = newWidgets
            try await loadWidgetData()
        } catch {
            errorMessage = "Unable to save dashboard configuration. Please try again."
            print("Widget configuration save error: \(error)")
        }
    }

    private func loadWidgetData() async throws {
        // Load inventory value
        if widgets.contains(where: { $0.metric == .inventoryValue && $0.isVisible }) {
            totalInventoryValue = try await Double(
                truncating: analyticsService.totalInventoryValue() as NSDecimalNumber)
        }

        // Load total items (always load for dashboard cards)
        totalItems = try await analyticsService.itemCount()

        // Calculate items per day (based on last 7 days)
        itemsPerDay = try await calculateItemsPerDay()

        // Load item count history for chart
        itemCountHistory = try await loadItemCountHistory()

        // Load stock alerts (empty for now - can be populated from low stock queries)
        stockAlerts = []

        // Load recent items
        recentItems = try await loadRecentItems()

        // Load recent activity
        if widgets.contains(where: { $0.metric == .recentActivity && $0.isVisible }) {
            recentActivity = try await loadRecentActivity()
        }

        // Load sales chart data
        if widgets.contains(where: { $0.metric == .salesOverview && $0.isVisible }) {
            salesChartData = try await loadSalesChartData()
        }
    }

    private func calculateItemsPerDay() async throws -> Int? {
        return try await analyticsService.itemsAddedLast24Hours()
    }

    private func loadItemCountHistory() async throws -> [ItemCountDataPoint] {
        let history = try await analyticsService.itemCountHistory(days: 7)
        return history.map { date, count in
            ItemCountDataPoint(date: date, count: count)
        }.sorted(by: { $0.date < $1.date })
    }

    private func loadRecentItems() async throws -> [RecentItemInfo] {
        let items = try await analyticsService.recentItems(limit: 10)
        return items.map { item in
            RecentItemInfo(
                title: item.title,
                brand: "Unknown",  // Placeholder as Item doesn't have brand name directly
                size: "-",  // Placeholder as Item doesn't have size directly
                condition: item.condition,  // condition is already a String
                price: item.purchasePrice.formatted(.currency(code: "USD")),
                query: "-",
                timestamp: item.dateAdded.formatted(date: .abbreviated, time: .shortened),
                imageURL: nil
            )
        }
    }

    private func loadRecentActivity() async throws -> [ActivityItem] {
        return try await analyticsService.getRecentActivity()
    }

    private func loadSalesChartData() async throws -> [SalesDataPoint] {
        return try await analyticsService.getSalesChartData()
    }
}
