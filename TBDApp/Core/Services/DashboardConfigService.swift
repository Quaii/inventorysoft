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

    func initializeDefaultLayout() async throws {
        let defaultWidgets = getDefaultWidgets()
        try await repository.saveAllWidgets(defaultWidgets)
    }

    func resetToDefaults() async throws {
        // Clear existing widgets and re-initialize with defaults
        try await repository.saveAllWidgets([])
        try await initializeDefaultLayout()
    }
    func getDefaultWidgets() -> [DashboardWidget] {
        return [
            DashboardWidget(
                metric: .inventoryValue,
                type: .stat,
                size: .small,
                isVisible: true,
                sortOrder: 0,
                chartType: nil,
                position: WidgetPosition(row: 0, col: 0)
            ),
            DashboardWidget(
                metric: .totalItems,
                type: .stat,
                size: .small,
                isVisible: true,
                sortOrder: 1,
                chartType: nil,
                position: WidgetPosition(row: 0, col: 1)
            ),
            DashboardWidget(
                metric: .lowStock,
                type: .stat,
                size: .small,
                isVisible: true,
                sortOrder: 2,
                chartType: nil,
                position: WidgetPosition(row: 0, col: 2)
            ),
            DashboardWidget(
                metric: .topSellingItems,
                type: .chart,
                size: .large,
                isVisible: true,
                sortOrder: 3,
                chartType: .bar,
                position: WidgetPosition(row: 1, col: 0)
            ),
            DashboardWidget(
                metric: .recentActivity,
                type: .list,
                size: .medium,
                isVisible: true,
                sortOrder: 4,
                chartType: nil,
                position: WidgetPosition(row: 2, col: 0)
            ),
        ]
    }
}
