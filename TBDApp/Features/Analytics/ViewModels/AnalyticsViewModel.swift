import Foundation
import SwiftUI

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var charts: [ChartDefinition] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Data caches for charts
    @Published var salesData: [SalesDataPoint] = []
    @Published var inventoryData: [Item] = []
    // Add other data sources as needed

    private let configService: AnalyticsConfigServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol

    init(
        configService: AnalyticsConfigServiceProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.configService = configService
        self.analyticsService = analyticsService
    }

    func loadCharts() async {
        isLoading = true
        errorMessage = nil
        do {
            charts = try await configService.getCharts()
            await loadData()
        } catch {
            errorMessage = "Failed to load charts: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func loadData() async {
        // Load data required for charts
        // This is a simplified approach; in a real app, we might load only what's needed
        do {
            salesData = try await analyticsService.getSalesChartData()
            // We might need a method to get all items for inventory charts
            // inventoryData = try await analyticsService.getAllItems()
        } catch {
            print("Error loading analytics data: \(error)")
        }
    }

    func addChart(_ chart: ChartDefinition) {
        Task {
            do {
                var newChart = chart
                newChart.sortOrder = charts.count
                try await configService.saveChart(newChart)
                await loadCharts()
            } catch {
                errorMessage = "Failed to add chart: \(error.localizedDescription)"
            }
        }
    }

    func updateChart(_ chart: ChartDefinition) {
        Task {
            do {
                try await configService.saveChart(chart)
                await loadCharts()
            } catch {
                errorMessage = "Failed to update chart: \(error.localizedDescription)"
            }
        }
    }

    func deleteChart(_ chart: ChartDefinition) {
        Task {
            do {
                try await configService.deleteChart(chart)
                await loadCharts()
            } catch {
                errorMessage = "Failed to delete chart: \(error.localizedDescription)"
            }
        }
    }

    func duplicateChart(_ chart: ChartDefinition) {
        var duplicate = chart.duplicated()
        // Ensure unique ID is handled in duplicated(), but let's be safe
        // duplicate.id = UUID() // duplicated() does this
        addChart(duplicate)
    }

    func reorderCharts(from source: IndexSet, to destination: Int) {
        var updatedCharts = charts
        updatedCharts.move(fromOffsets: source, toOffset: destination)

        // Update sort order
        for (index, _) in updatedCharts.enumerated() {
            updatedCharts[index].sortOrder = index
        }

        charts = updatedCharts

        Task {
            do {
                try await configService.updateChartOrder(updatedCharts)
            } catch {
                errorMessage = "Failed to save chart order: \(error.localizedDescription)"
            }
        }
    }
}
