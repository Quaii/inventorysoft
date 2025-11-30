import Combine
import Foundation

struct ActivityItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let type: ActivityType
    let date: Date

    enum ActivityType {
        case sale
        case purchase
    }
}

struct SalesDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

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
    @Published var stockAlerts: [String] = []
    @Published var recentActivity: [ActivityItem] = []
    @Published var salesChartData: [SalesDataPoint] = []

    // New dashboard card properties
    @Published var itemsPerDay: Int? = nil
    @Published var processes: [ProcessInfo] = []
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
            if let technicalError = error as? NSError {
                print("Technical details: \(technicalError.userInfo)")
            }
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

        // Load processes (empty for now - can be populated from app configuration)
        processes = []

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
        // TODO: Implement actual query to count items added in last 24 hours
        // For now, return nil to show "—" in UI
        return nil
    }

    private func loadItemCountHistory() async throws -> [ItemCountDataPoint] {
        // TODO: Implement actual query to get item count by day for last 7 days
        // For now, return empty array to show "No data yet" placeholder
        return []
    }

    private func loadRecentItems() async throws -> [RecentItemInfo] {
        // TODO: Implement actual query to fetch last 5-10 items from inventory
        // For now, return empty array to show empty state
        return []
    }

    private func loadRecentActivity() async throws -> [ActivityItem] {
        // TODO: Implement actual query to fetch recent sales and purchases
        // For now, return empty array
        return []
    }

    private func loadSalesChartData() async throws -> [SalesDataPoint] {
        // TODO: Implement actual query using analytics service
        // For now, return empty array
        return []
    }
}
