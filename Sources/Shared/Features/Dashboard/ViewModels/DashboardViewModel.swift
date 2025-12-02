import Combine
import Foundation

@MainActor
public class DashboardViewModel: ObservableObject {
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

    // KPI data
    @Published var kpis: [DashboardKPI] = []

    // Quick list data
    @Published var recentSales: [QuickListItem] = []
    @Published var recentPurchases: [QuickListItem] = []
    @Published var recentlyAddedItems: [QuickListItem] = []

    // User-added widgets (Phase 5)
    @Published var userWidgets: [UserWidget] = []

    // New dashboard card properties
    @Published var itemsPerDay: Int? = nil
    @Published var stockAlerts: [StockAlert] = []
    @Published var recentItems: [RecentItemInfo] = []
    @Published var itemCountHistory: [ItemCountDataPoint] = []

    private let userWidgetRepository: UserWidgetRepositoryProtocol
    private let inventoryViewModel: InventoryViewModel
    private let salesViewModel: SalesViewModel
    private let purchasesViewModel: PurchasesViewModel
    private let kpiService: KPIServiceProtocol
    private let kpiService: KPIServiceProtocol

    public init(
        dashboardConfigService: DashboardConfigServiceProtocol,
        analyticsService: AnalyticsServiceProtocol,
        kpiService: KPIServiceProtocol,
        inventoryViewModel: InventoryViewModel,
        salesViewModel: SalesViewModel,
        purchasesViewModel: PurchasesViewModel
    ) {
        self.dashboardConfigService = dashboardConfigService
        self.analyticsService = analyticsService
        self.kpiService = kpiService
        self.inventoryViewModel = inventoryViewModel
        self.salesViewModel = salesViewModel
        self.purchasesViewModel = purchasesViewModel
        self.userWidgetRepository = UserWidgetRepository()
    }

    /// Get KPI data for a specific widget type
    func getKPIData(for widgetType: DashboardWidgetType) -> DashboardKPI? {
        guard let metricType = widgetType.kpiMetricType else { return nil }
        return kpis.first { $0.metricKey == metricType }
    }

    func loadMetrics() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load widgets configuration
            widgets = try await dashboardConfigService.getWidgets()

            // Load user widgets from repository
            userWidgets = try await userWidgetRepository.getAllWidgets()

            // If no widgets exist, create default layout
            if userWidgets.isEmpty {
                userWidgets = createDefaultWidgets()
                try await userWidgetRepository.saveAllWidgets(userWidgets)
            }

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

            // Reset user widgets to defaults
            try await userWidgetRepository.deleteAllWidgets()
            userWidgets = createDefaultWidgets()
            try await userWidgetRepository.saveAllWidgets(userWidgets)

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

    // MARK: - Widget Management

    func addWidget(type: DashboardWidgetType, size: DashboardWidgetSize, name: String) {
        let newWidget = UserWidget(
            type: type,
            size: size,
            name: name,
            position: userWidgets.count
        )
        userWidgets.append(newWidget)

        Task {
            try? await userWidgetRepository.saveWidget(newWidget)
        }
        print("Added widget: \(name) (\(type.rawValue), \(size.rawValue))")
    }

    func duplicateWidget(_ widget: UserWidget) {
        let duplicateWidget = UserWidget(
            type: widget.type,
            size: widget.size,
            name: "\(widget.name) Copy",
            position: userWidgets.count,
            configuration: widget.configuration,
            isVisible: widget.isVisible
        )
        userWidgets.append(duplicateWidget)

        Task {
            try? await userWidgetRepository.saveWidget(duplicateWidget)
        }
        print("Duplicated widget: \(widget.name)")
    }

    func changeWidgetSize(_ widget: UserWidget, to newSize: DashboardWidgetSize) {
        if let index = userWidgets.firstIndex(where: { $0.id == widget.id }) {
            userWidgets[index].size = newSize
            let updatedWidget = userWidgets[index]

            Task {
                try? await userWidgetRepository.saveWidget(updatedWidget)
            }
            print("Changed widget size: \(widget.name) to \(newSize.rawValue)")
        }
    }

    func reorderWidget(from source: IndexSet, to destination: Int) {
        userWidgets.move(fromOffsets: source, toOffset: destination)

        // Update positions
        for (index, _) in userWidgets.enumerated() {
            userWidgets[index].position = index
        }

        Task {
            try? await userWidgetRepository.saveAllWidgets(userWidgets)
        }
        print("Reordered widgets")
    }

    func reorderWidget(from sourceWidget: UserWidget, to destinationWidget: UserWidget) {
        guard let sourceIndex = userWidgets.firstIndex(where: { $0.id == sourceWidget.id }),
            let destinationIndex = userWidgets.firstIndex(where: { $0.id == destinationWidget.id })
        else { return }

        userWidgets.move(
            fromOffsets: IndexSet(integer: sourceIndex),
            toOffset: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex)

        // Update positions
        for (index, _) in userWidgets.enumerated() {
            userWidgets[index].position = index
        }

        Task {
            try? await userWidgetRepository.saveAllWidgets(userWidgets)
        }
        print("Reordered widgets")
    }

    func updateWidget(_ updatedWidget: UserWidget) {
        if let index = userWidgets.firstIndex(where: { $0.id == updatedWidget.id }) {
            userWidgets[index] = updatedWidget

            Task {
                try? await userWidgetRepository.saveWidget(updatedWidget)
            }
            print("Updated widget: \(updatedWidget.name)")
        }
    }

    func removeWidget(_ widget: UserWidget) {
        userWidgets.removeAll { $0.id == widget.id }

        Task {
            try? await userWidgetRepository.deleteWidget(id: widget.id)
        }
        print("Removed widget: \(widget.id)")
    }

    func removeWidget(id: UUID) {
        userWidgets.removeAll { $0.id == id }

        Task {
            try? await userWidgetRepository.deleteWidget(id: id)
        }
        print("Removed widget: \(id)")
    }

    private func loadWidgetData() async throws {
        // Load KPIs
        await loadKPIs()

        // Load Quick Lists
        await loadQuickLists()

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
        return history.sorted(by: { $0.date < $1.date })
    }

    private func loadRecentItems() async throws -> [RecentItemInfo] {
        return try await analyticsService.recentItems(limit: 10)
    }

    private func loadRecentActivity() async throws -> [ActivityItem] {
        return try await analyticsService.getRecentActivity()
    }

    private func loadSalesChartData() async throws -> [SalesDataPoint] {
        return try await analyticsService.getSalesChartData()
    }

    // MARK: - KPI Calculations

    func loadKPIs() async {
        do {
            kpis = try await kpiService.calculateKPIs()
        } catch {
            print("KPI calculation error: \(error)")
            // Set empty KPIs on error
            kpis = []
        }
    }

    // MARK: - Alert Generation
    // Alerts removed as per system audit

    func handleKPITap(_ kpi: DashboardKPI) {
        print("Tapped KPI: \(kpi.title) - Metric: \(kpi.metricKey.rawValue)")
        // Future: Navigate to detailed view based on KPI type
        // For now, KPI widgets in the unified system handle their own tap events
    }

    // MARK: - Quick Lists

    func loadQuickLists() async {
        do {
            async let sales = loadRecentSales()
            async let purchases = loadRecentPurchases()
            async let items = loadRecentlyAddedItems()

            (recentSales, recentPurchases, recentlyAddedItems) = try await (sales, purchases, items)
        } catch {
            print("Quick lists load error: \(error)")
            recentSales = []
            recentPurchases = []
            recentlyAddedItems = []
        }
    }

    private func loadRecentSales() async throws -> [QuickListItem] {
        // This would fetch last 5 sales from repository
        // Placeholder for now
        return []
    }

    private func loadRecentPurchases() async throws -> [QuickListItem] {
        // This would fetch last 5 purchases from repository
        // Placeholder for now
        return []
    }

    private func loadRecentlyAddedItems() async throws -> [QuickListItem] {
        // Convert existing recentItems to QuickListItem format
        return recentItems.prefix(5).map { item in
            QuickListItem(
                icon: "shippingbox",
                title: item.title,
                subtitle: item.dateAdded.formatted(date: .abbreviated, time: .shortened),
                value: item.price.formatted(.currency(code: "USD"))
            )
        }
    }

    // MARK: - Default Widget Creation

    /// Creates the default widget layout matching the current dashboard structure
    ///
    /// Default layout includes:
    /// - Row 1: 6 KPI widgets (inventory value, items in stock, items listed, sold month, revenue month, profit month)
    /// - Row 2: 1 priority alerts widget
    /// - Row 3: 3 quick list widgets (recent sales, purchases, items)
    ///
    /// Total: 10 widgets in default configuration
    private func createDefaultWidgets() -> [UserWidget] {
        var widgets: [UserWidget] = []
        var position = 0

        // Row 1: KPI Widgets (6 small widgets)
        let kpiTypes: [DashboardWidgetType] = [
            .kpiInventoryValue,
            .kpiItemsInStock,
            .kpiItemsListed,
            .kpiSoldMonth,
            .kpiRevenueMonth,
            .kpiProfitMonth,
        ]

        for kpiType in kpiTypes {
            widgets.append(
                UserWidget(
                    type: kpiType,
                    size: .small,
                    name: kpiType.displayName,
                    position: position
                ))
            position += 1
        }

        // Row 2: Priority Alerts (Removed)
        // widgets.append(...)

        // Row 3: Quick Lists (3 medium widgets)
        widgets.append(
            UserWidget(
                type: .quickListSales,
                size: .medium,
                name: "Recent Sales",
                position: position
            ))
        position += 1

        widgets.append(
            UserWidget(
                type: .quickListPurchases,
                size: .medium,
                name: "Recent Purchases",
                position: position
            ))
        position += 1

        widgets.append(
            UserWidget(
                type: .quickListItems,
                size: .medium,
                name: "Recent Items",
                position: position
            ))

        return widgets
    }
}
