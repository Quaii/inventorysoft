import Foundation
import SwiftUI

// MARK: - Dashboard Configuration

enum DashboardMetric: String, Codable, CaseIterable, Identifiable {
    case inventoryValue = "Inventory Value"
    case totalItems = "Total Items"
    case itemsPerDay = "Items Added / Day"
    case salesOverview = "Sales Overview"
    case recentActivity = "Recent Activity"
    case lowStock = "Low Stock Alerts"
    case itemsInStock = "Items in Stock"
    case itemsSoldThisWeek = "Items Sold This Week"
    case topSellingItems = "Top Selling Items"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

enum WidgetType: String, Codable {
    case stat
    case chart
    case list
    case alert
    case text

    var icon: String {
        switch self {
        case .stat: return "number"
        case .chart: return "chart.xyaxis.line"
        case .list: return "list.bullet"
        case .alert: return "exclamationmark.triangle"
        case .text: return "text.alignleft"
        }
    }
}

enum WidgetSize: String, Codable, CaseIterable {
    case small
    case medium
    case large
}

struct WidgetPosition: Codable, Equatable {
    var row: Int
    var col: Int
}

struct DashboardWidget: Identifiable, Codable, Equatable {
    let id: UUID
    var metric: DashboardMetric
    var type: WidgetType
    var size: WidgetSize
    var isVisible: Bool
    var sortOrder: Int
    var chartType: ChartType?
    var positionRow: Int
    var positionCol: Int

    var position: WidgetPosition {
        get { WidgetPosition(row: positionRow, col: positionCol) }
        set {
            positionRow = newValue.row
            positionCol = newValue.col
        }
    }

    init(
        id: UUID = UUID(),
        metric: DashboardMetric,
        type: WidgetType,
        size: WidgetSize = .medium,
        isVisible: Bool = true,
        sortOrder: Int = 0,
        chartType: ChartType? = nil,
        position: WidgetPosition = WidgetPosition(row: 0, col: 0)
    ) {
        self.id = id
        self.metric = metric
        self.type = type
        self.size = size
        self.isVisible = isVisible
        self.sortOrder = sortOrder
        self.chartType = chartType
        self.positionRow = position.row
        self.positionCol = position.col
    }
}

// MARK: - Data Models

struct ActivityItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: ActivityType
    let date: Date

    enum ActivityType: String, Codable {
        case sale
        case purchase
        case alert
    }
}

struct SalesDataPoint: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct ItemCountDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct RecentItemInfo: Identifiable {
    let id = UUID()
    let title: String
    let brand: String
    let size: String
    let condition: String
    let price: String
    let query: String
    let timestamp: String
    let imageURL: String?
}

struct CategoryDataPoint: Identifiable, Codable {
    let id: UUID
    let category: String
    let value: Double

    init(id: UUID = UUID(), category: String, value: Double) {
        self.id = id
        self.category = category
        self.value = value
    }
}

struct TopProductInfo: Identifiable, Codable {
    let id: UUID
    let name: String
    let revenue: Double

    init(id: UUID = UUID(), name: String, revenue: Double) {
        self.id = id
        self.name = name
        self.revenue = revenue
    }
}
