import Foundation

enum WidgetType: String, Codable, CaseIterable {
    case kpi
    case chart
    case list
    case text

    var icon: String {
        switch self {
        case .kpi: return "number.circle"
        case .chart: return "chart.bar"
        case .list: return "list.bullet"
        case .text: return "text.alignleft"
        }
    }
}

enum WidgetMetric: String, Codable, CaseIterable {
    case inventoryValue
    case itemsInStock
    case itemsListed
    case itemsSoldThisWeek
    case profitThisMonth
    case avgHoldTime
    case recentActivity
    case salesOverview

    var displayName: String {
        switch self {
        case .inventoryValue: return "Total Inventory Value"
        case .itemsInStock: return "Items in Stock"
        case .itemsListed: return "Items Listed"
        case .itemsSoldThisWeek: return "Items Sold This Week"
        case .profitThisMonth: return "Profit This Month"
        case .avgHoldTime: return "Average Hold Time"
        case .recentActivity: return "Recent Activity"
        case .salesOverview: return "Sales Overview"
        }
    }

    var defaultWidgetType: WidgetType {
        switch self {
        case .recentActivity: return .list
        case .salesOverview: return .chart
        default: return .kpi
        }
    }
}

enum WidgetSize: String, Codable, CaseIterable {
    case small
    case medium
    case large

    var columns: Int {
        switch self {
        case .small: return 1
        case .medium: return 2
        case .large: return 3
        }
    }
}

enum ChartType: String, Codable, CaseIterable {
    case none
    case bar
    case line
    case area
    case donut

    var displayName: String {
        switch self {
        case .none: return "None"
        case .bar: return "Bar Chart"
        case .line: return "Line Chart"
        case .area: return "Area Chart"
        case .donut: return "Donut Chart"
        }
    }

    var icon: String {
        switch self {
        case .none: return "minus.circle"
        case .bar: return "chart.bar"
        case .line: return "chart.xyaxis.line"
        case .area: return "chart.line.uptrend.xyaxis"
        case .donut: return "chart.pie"
        }
    }
}

struct WidgetPosition: Codable, Equatable {
    var row: Int
    var col: Int

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

struct DashboardWidget: Identifiable, Codable, Equatable {
    let id: UUID
    var type: WidgetType
    var metric: WidgetMetric
    var size: WidgetSize
    var position: WidgetPosition
    var chartType: ChartType
    var isVisible: Bool
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        type: WidgetType,
        metric: WidgetMetric,
        size: WidgetSize,
        position: WidgetPosition,
        chartType: ChartType = .none,
        isVisible: Bool = true,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.type = type
        self.metric = metric
        self.size = size
        self.position = position
        self.chartType = chartType
        self.isVisible = isVisible
        self.sortOrder = sortOrder
    }
}
