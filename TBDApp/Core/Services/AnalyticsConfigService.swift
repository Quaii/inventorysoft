import Foundation

protocol AnalyticsConfigServiceProtocol {
    func getCharts() async throws -> [ChartDefinition]
    func saveChart(_ chart: ChartDefinition) async throws
    func deleteChart(_ chart: ChartDefinition) async throws
    func updateChartOrder(_ charts: [ChartDefinition]) async throws
    func resetToDefaults() async throws
}

class AnalyticsConfigService: AnalyticsConfigServiceProtocol {
    private let repository: AnalyticsConfigRepositoryProtocol

    init(repository: AnalyticsConfigRepositoryProtocol) {
        self.repository = repository
    }

    func getCharts() async throws -> [ChartDefinition] {
        let charts = try await repository.fetchCharts()
        if charts.isEmpty {
            // Return defaults if no charts exist
            let defaults = [
                ChartDefinition.revenueTrend,
                ChartDefinition.salesByCategory,
                ChartDefinition.topProducts,
            ]
            // Persist defaults so they exist for next time
            for chart in defaults {
                try await repository.saveChart(chart)
            }
            return defaults
        }
        return charts
    }

    func saveChart(_ chart: ChartDefinition) async throws {
        try await repository.saveChart(chart)
    }

    func deleteChart(_ chart: ChartDefinition) async throws {
        try await repository.deleteChart(chart)
    }

    func updateChartOrder(_ charts: [ChartDefinition]) async throws {
        try await repository.updateChartOrder(charts)
    }

    func resetToDefaults() async throws {
        let currentCharts = try await repository.fetchCharts()
        for chart in currentCharts {
            try await repository.deleteChart(chart)
        }

        let defaults = [
            ChartDefinition.revenueTrend,
            ChartDefinition.salesByCategory,
            ChartDefinition.topProducts,
        ]
        for chart in defaults {
            try await repository.saveChart(chart)
        }
    }
}
