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
    private let preferencesRepo: UserPreferencesRepositoryProtocol

    init(
        repository: AnalyticsConfigRepositoryProtocol,
        preferencesRepo: UserPreferencesRepositoryProtocol
    ) {
        self.repository = repository
        self.preferencesRepo = preferencesRepo
    }

    func getCharts() async throws -> [ChartDefinition] {
        let charts = try await repository.fetchCharts()
        let preferences = try await preferencesRepo.getPreferences()

        // Only create defaults on TRUE first run (never customized before)
        if charts.isEmpty && !preferences.hasCustomizedAnalytics {
            let defaults = [
                ChartDefinition.revenueTrend,
                ChartDefinition.salesByCategory,
                ChartDefinition.topProducts,
            ]
            // Persist defaults
            for chart in defaults {
                try await repository.saveChart(chart)
            }
            // Mark as customized so we don't auto-recreate if user deletes all
            var updatedPrefs = preferences
            updatedPrefs.hasCustomizedAnalytics = true
            try await preferencesRepo.savePreferences(updatedPrefs)
            return defaults
        }
        return charts
    }

    func saveChart(_ chart: ChartDefinition) async throws {
        try await repository.saveChart(chart)
        // Mark as customized
        var preferences = try await preferencesRepo.getPreferences()
        preferences.hasCustomizedAnalytics = true
        try await preferencesRepo.savePreferences(preferences)
    }

    func deleteChart(_ chart: ChartDefinition) async throws {
        try await repository.deleteChart(chart)
        // Mark as customized
        var preferences = try await preferencesRepo.getPreferences()
        preferences.hasCustomizedAnalytics = true
        try await preferencesRepo.savePreferences(preferences)
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
