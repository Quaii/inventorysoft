import Foundation
import SwiftUI

// MARK: - Dashboard Configuration

public enum DashboardMetric: String, Codable, CaseIterable, Identifiable {
    case inventoryValue = "Inventory Value"
    case totalItems = "Total Items"
    case itemsPerDay = "Items Added / Day"
    case salesOverview = "Sales Overview"
    case recentActivity = "Recent Activity"
    case lowStock = "Low Stock Alerts"
    case itemsInStock = "Items in Stock"
    case itemsSoldThisWeek = "Items Sold This Week"
    case topSellingItems = "Top Selling Items"

    public var id: String { rawValue }

    public var displayName: String { rawValue }
}

public enum WidgetType: String, Codable {
    case stat
    case chart
    case list
    case alert
    case text

    public var icon: String {
        switch self {
        case .stat: return "number"
        case .chart: return "chart.xyaxis.line"
        case .list: return "list.bullet"
        case .alert: return "exclamationmark.triangle"
        case .text: return "text.alignleft"
        }
    }
}

public enum WidgetSize: String, Codable, CaseIterable {
    case small
    case medium
    case large
}

// ChartType moved to ChartDefinition.swift

public struct WidgetPosition: Codable, Equatable {
    public var row: Int
    public var col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

public struct DashboardWidget: Identifiable, Codable, Equatable {
    public let id: UUID
    public var metric: DashboardMetric
    public var type: WidgetType
    public var size: WidgetSize
    public var isVisible: Bool
    public var sortOrder: Int
    public var chartType: ChartType?
    public var positionRow: Int
    public var positionCol: Int

    public var position: WidgetPosition {
        get { WidgetPosition(row: positionRow, col: positionCol) }
        set {
            positionRow = newValue.row
            positionCol = newValue.col
        }
    }

    public init(
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

// ActivityItem moved to AnalyticsModels.swift

// SalesDataPoint moved to AnalyticsModels.swift

// ItemCountDataPoint moved to AnalyticsModels.swift

// RecentItemInfo moved to AnalyticsModels.swift

// CategoryDataPoint moved to AnalyticsModels.swift

// TopProductInfo moved to AnalyticsModels.swift
