import Foundation

/// Represents a Key Performance Indicator card on the dashboard
struct DashboardKPI: Identifiable, Codable {
    let id: UUID
    var title: String
    var value: String  // Formatted display value (e.g., "$1,234" or "42 items")
    var secondaryText: String?  // Optional context (e.g., "This month", "+12% from last month")
    var metricKey: KPIMetricType
    var isVisible: Bool
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        title: String,
        value: String,
        secondaryText: String? = nil,
        metricKey: KPIMetricType,
        isVisible: Bool = true,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.secondaryText = secondaryText
        self.metricKey = metricKey
        self.isVisible = isVisible
        self.sortOrder = sortOrder
    }
}

/// Types of KPI metrics available
enum KPIMetricType: String, Codable, CaseIterable {
    case inventoryValue = "inventory_value"
    case itemsInStock = "items_in_stock"
    case itemsListed = "items_listed"
    case itemsSoldMonth = "items_sold_month"
    case revenueMonth = "revenue_month"
    case profitMonth = "profit_month"

    var defaultTitle: String {
        switch self {
        case .inventoryValue: return "Inventory Value"
        case .itemsInStock: return "Items in Stock"
        case .itemsListed: return "Items Listed"
        case .itemsSoldMonth: return "Sold This Month"
        case .revenueMonth: return "Revenue (Month)"
        case .profitMonth: return "Profit (Month)"
        }
    }

    var icon: String {
        switch self {
        case .inventoryValue: return "dollarsign.circle"
        case .itemsInStock: return "shippingbox"
        case .itemsListed: return "list.bullet.clipboard"
        case .itemsSoldMonth: return "cart"
        case .revenueMonth: return "banknote"
        case .profitMonth: return "chart.line.uptrend.xyaxis"
        }
    }
}
