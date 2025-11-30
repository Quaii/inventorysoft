import Foundation

protocol DashboardConfigServiceProtocol {
    func getWidgets() async throws -> [DashboardWidget]
    func saveWidgetConfiguration(_ widgets: [DashboardWidget]) async throws
    func getDefaultWidgets() -> [DashboardWidget]
    func initializeDefaultLayout() async throws
    func resetToDefaults() async throws
}

class DashboardConfigService: DashboardConfigServiceProtocol {
    private let repository: DashboardConfigRepositoryProtocol

    init(repository: DashboardConfigRepositoryProtocol = DashboardConfigRepository()) {
        self.repository = repository
    }

    func getWidgets() async throws -> [DashboardWidget] {
        let widgets = try await repository.getAllWidgets()

        // If no widgets exist, initialize with defaults
        if widgets.isEmpty {
            try await initializeDefaultLayout()
            return try await repository.getAllWidgets()
        }

        return widgets
    }

    func saveWidgetConfiguration(_ widgets: [DashboardWidget]) async throws {
        try await repository.saveAllWidgets(widgets)
    }

    func getDefaultWidgets() -> [DashboardWidget] {
        [
            // Row 0
            DashboardWidget(
                type: .kpi,
                metric: .inventoryValue,
                size: .small,
                position: WidgetPosition(row: 0, col: 0),
                chartType: .none,
                isVisible: true,
                sortOrder: 0
            ),
            DashboardWidget(
                type: .kpi,
                metric: .itemsInStock,
                size: .small,
                position: WidgetPosition(row: 0, col: 1),
                chartType: .none,
                isVisible: true,
                sortOrder: 1
            ),
            DashboardWidget(
                type: .kpi,
                metric: .itemsSoldThisWeek,
                size: .small,
                position: WidgetPosition(row: 0, col: 2),
                chartType: .none,
                isVisible: true,
                sortOrder: 2
            ),
            // Row 1
            DashboardWidget(
                type: .list,
                metric: .recentActivity,
                size: .medium,
                position: WidgetPosition(row: 1, col: 0),
                chartType: .none,
                isVisible: true,
                sortOrder: 3
            ),
            DashboardWidget(
                type: .chart,
                metric: .salesOverview,
                size: .medium,
                position: WidgetPosition(row: 1, col: 1),
                chartType: .bar,
                isVisible: true,
                sortOrder: 4
            ),
        ]
    }

    func initializeDefaultLayout() async throws {
        let defaultWidgets = getDefaultWidgets()
        try await repository.saveAllWidgets(defaultWidgets)
    }

    func resetToDefaults() async throws {
        // Clear existing widgets and re-initialize with defaults
        try await repository.saveAllWidgets([])
        try await initializeDefaultLayout()
    }
}
