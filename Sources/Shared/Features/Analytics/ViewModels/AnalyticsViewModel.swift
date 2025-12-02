import Foundation
import SwiftUI

@MainActor
public class AnalyticsViewModel: ObservableObject {
    @Published var widgets: [UserWidget] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Data caches for charts
    @Published var salesData: [SalesDataPoint] = []
    @Published var inventoryData: [Item] = []
    // Add other data sources as needed

    private let widgetRepository: AnalyticsWidgetRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let configService: AnalyticsConfigServiceProtocol
    private let exportService: ExportService

    public init(
        widgetRepository: AnalyticsWidgetRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol,
        configService: AnalyticsConfigServiceProtocol,
        exportService: ExportService
    ) {
        self.widgetRepository = widgetRepository
        self.analyticsService = analyticsService
        self.configService = configService
        self.exportService = exportService
    }

    func loadWidgets() async {
        isLoading = true
        errorMessage = nil
        do {
            widgets = try await widgetRepository.getAllWidgets()

            // If no widgets exist, create default layout
            if widgets.isEmpty {
                widgets = createDefaultWidgets()
                try await widgetRepository.saveAllWidgets(widgets)
            }

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

    func addWidget(type: DashboardWidgetType, size: DashboardWidgetSize, name: String) {
        let newWidget = UserWidget(
            type: type,
            size: size,
            name: name,
            position: widgets.count
        )
        widgets.append(newWidget)

        Task {
            try? await widgetRepository.saveWidget(newWidget)
        }
        print("Added chart widget: \(name) (\(type.rawValue), \(size.rawValue))")
    }

    func updateWidget(_ widget: UserWidget) {
        Task {
            do {
                try await widgetRepository.saveWidget(widget)
                await loadWidgets()
            } catch {
                errorMessage = "Failed to update chart: \(error.localizedDescription)"
            }
        }
    }

    func removeWidget(_ widget: UserWidget) {
        widgets.removeAll { $0.id == widget.id }

        Task {
            try? await widgetRepository.deleteWidget(id: widget.id)
        }
    }

    func duplicateWidget(_ widget: UserWidget) {
        let duplicateWidget = UserWidget(
            type: widget.type,
            size: widget.size,
            name: "\(widget.name) Copy",
            position: widgets.count,
            configuration: widget.configuration,
            isVisible: widget.isVisible
        )
        widgets.append(duplicateWidget)

        Task {
            try? await widgetRepository.saveWidget(duplicateWidget)
        }
        print("Duplicated widget: \(widget.name)")
    }

    func changeWidgetSize(_ widget: UserWidget, to newSize: DashboardWidgetSize) {
        if let index = widgets.firstIndex(where: { $0.id == widget.id }) {
            var updatedWidget = widgets[index]
            updatedWidget.size = newSize
            widgets[index] = updatedWidget

            Task {
                try? await widgetRepository.saveWidget(updatedWidget)
            }
        }
    }

    func reorderWidgets(from source: IndexSet, to destination: Int) {
        widgets.move(fromOffsets: source, toOffset: destination)

        // Update positions
        for (index, _) in widgets.enumerated() {
            widgets[index].position = index
        }

        Task {
            try? await widgetRepository.saveAllWidgets(widgets)
        }
    }

    func reorderWidgets(from sourceWidget: UserWidget, to destinationWidget: UserWidget) {
        guard let sourceIndex = widgets.firstIndex(where: { $0.id == sourceWidget.id }),
            let destinationIndex = widgets.firstIndex(where: { $0.id == destinationWidget.id })
        else { return }

        widgets.move(
            fromOffsets: IndexSet(integer: sourceIndex),
            toOffset: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex)

        // Update positions
        for (index, _) in widgets.enumerated() {
            widgets[index].position = index
        }

        Task {
            try? await widgetRepository.saveAllWidgets(widgets)
        }
    }

    func resetToDefaults() {
        Task {
            do {
                try await widgetRepository.deleteAllWidgets()
                widgets = createDefaultWidgets()
                try await widgetRepository.saveAllWidgets(widgets)
            } catch {
                errorMessage = "Failed to reset charts: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Default Widgets

    private func createDefaultWidgets() -> [UserWidget] {
        var widgets: [UserWidget] = []
        var position = 0

        // Default chart 1: Revenue Trend
        widgets.append(
            UserWidget(
                type: .revenueChart,
                size: .large,
                name: "Revenue Trend",
                position: position
            ))
        position += 1

        // Default chart 2: Sales by Category
        widgets.append(
            UserWidget(
                type: .topCategories,
                size: .medium,
                name: "Sales by Category",
                position: position
            ))
        position += 1

        // Default chart 3: Top Products
        widgets.append(
            UserWidget(
                type: .itemsSoldOverTime,
                size: .medium,
                name: "Items Sold Over Time",
                position: position
            ))

        return widgets
    }
}
