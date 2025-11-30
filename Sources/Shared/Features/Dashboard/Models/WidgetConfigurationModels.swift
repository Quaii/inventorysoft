import Foundation

// MARK: - Widget Configuration Protocol

/// Base protocol for all widget configurations
///
/// Widget configurations are stored as JSON data in the database and decoded
/// when widgets are loaded. Each widget type has its own configuration struct
/// that conforms to this protocol.
protocol WidgetConfiguration: Codable, Equatable {
    /// Returns a default configuration for this type
    static var `default`: Self { get }
}

// MARK: - KPI Widget Configuration

/// Configuration for KPI (Key Performance Indicator) widgets
///
/// KPI widgets display a single metric value with optional secondary text.
/// They can be configured to show different metrics (inventory value, items in stock, etc.)
/// and optionally filter by time range.
///
/// ## Usage
/// ```swift
/// let config = KPIWidgetConfig(
///     metricType: .inventoryValue,
///     timeRange: .last30Days,
///     customTitle: "Current Inventory"
/// )
/// ```
struct KPIWidgetConfig: WidgetConfiguration {
    /// The KPI metric to display
    var metricType: KPIMetricType

    /// Optional time range filter for metrics that support it
    var timeRange: TimeRange?

    /// Custom title to override the metric's default title
    var customTitle: String?

    static var `default`: KPIWidgetConfig {
        KPIWidgetConfig(metricType: .inventoryValue, timeRange: nil, customTitle: nil)
    }
}

/// Time range options for filtering metrics
enum TimeRange: String, Codable {
    case today = "today"
    case last7Days = "last_7_days"
    case last30Days = "last_30_days"
    case thisMonth = "this_month"
    case lastMonth = "last_month"
    case thisYear = "this_year"
    case allTime = "all_time"

    var displayName: String {
        switch self {
        case .today: return "Today"
        case .last7Days: return "Last 7 Days"
        case .last30Days: return "Last 30 Days"
        case .thisMonth: return "This Month"
        case .lastMonth: return "Last Month"
        case .thisYear: return "This Year"
        case .allTime: return "All Time"
        }
    }
}

// MARK: - List Widget Configuration

/// Configuration for quick list widgets
///
/// Quick list widgets display recent activity (sales, purchases, or items).
/// They can be configured to show different types of data and control how many rows are displayed.
///
/// ## Usage
/// ```swift
/// let config = ListWidgetConfig(
///     listType: .sales,
///     rowCount: 5,
///     customTitle: "Today's Sales"
/// )
/// ```
struct ListWidgetConfig: WidgetConfiguration {
    /// The type of list to display
    var listType: QuickListType

    /// Number of items to show in the list (3-10)
    var rowCount: Int

    /// Custom title to override the default
    var customTitle: String?

    static var `default`: ListWidgetConfig {
        ListWidgetConfig(listType: .sales, rowCount: 5, customTitle: nil)
    }

    init(listType: QuickListType, rowCount: Int = 5, customTitle: String? = nil) {
        self.listType = listType
        self.rowCount = min(max(rowCount, 3), 10)  // Clamp between 3-10
        self.customTitle = customTitle
    }
}

/// Types of quick lists available
enum QuickListType: String, Codable {
    case sales = "sales"
    case purchases = "purchases"
    case items = "items"

    var defaultTitle: String {
        switch self {
        case .sales: return "Recent Sales"
        case .purchases: return "Recent Purchases"
        case .items: return "Recent Items"
        }
    }

    var icon: String {
        switch self {
        case .sales: return "cart"
        case .purchases: return "bag"
        case .items: return "shippingbox"
        }
    }
}

// MARK: - Alert Widget Configuration

/// Configuration for priority alert widgets
///
/// Alert widgets display important notifications and warnings to the user.
/// They can be configured to show specific categories of alerts.
///
/// ## Usage
/// ```swift
/// let config = AlertWidgetConfig(
///     alertCategories: [.agingItems, .lowStock],
///     customTitle: "Important Alerts"
/// )
/// ```
struct AlertWidgetConfig: WidgetConfiguration {
    /// Categories of alerts to display
    var alertCategories: [AlertCategory]

    /// Custom title for the alerts section
    var customTitle: String?

    static var `default`: AlertWidgetConfig {
        AlertWidgetConfig(
            alertCategories: AlertCategory.allCases,
            customTitle: nil
        )
    }
}

/// Alert categories that can be displayed
enum AlertCategory: String, Codable, CaseIterable {
    case agingItems = "aging_items"
    case lowStock = "low_stock"
    case profitTrend = "profit_trend"
    case bestBrand = "best_brand"

    var displayName: String {
        switch self {
        case .agingItems: return "Aging Items"
        case .lowStock: return "Low Stock"
        case .profitTrend: return "Profit Trend"
        case .bestBrand: return "Best Brand"
        }
    }
}

// MARK: - Chart Widget Configuration

/// Configuration for chart widgets
///
/// Chart widgets display data visualizations (revenue, profit, sales volume, etc.)
/// with customizable chart types, metrics, time ranges, and styling.
///
/// ## Usage
/// ```swift
/// let config = ChartWidgetConfig(
///     metric: .revenue,
///     chartType: .line,
///     timeRange: .last30Days,
///     customTitle: "Monthly Revenue Trend"
/// )
/// ```
struct ChartWidgetConfig: WidgetConfiguration {
    /// The metric to chart
    var metric: ChartMetric

    /// Visual chart type
    var chartType: ChartType

    /// Time range for the data
    var timeRange: TimeRange

    /// Custom title to override the default
    var customTitle: String?

    /// Optional color scheme override
    var colorScheme: String?

    /// For custom formula widgets
    var customFormula: String?

    static var `default`: ChartWidgetConfig {
        ChartWidgetConfig(
            metric: .revenue,
            chartType: .line,
            timeRange: .last30Days,
            customTitle: nil,
            colorScheme: nil,
            customFormula: nil
        )
    }
}

/// Metrics available for charting
enum ChartMetric: String, Codable {
    case revenue = "revenue"
    case profit = "profit"
    case itemsSold = "items_sold"
    case averageSalePrice = "average_sale_price"
    case topCategories = "top_categories"
    case topBrands = "top_brands"
    case customFormula = "custom_formula"

    var displayName: String {
        switch self {
        case .revenue: return "Revenue"
        case .profit: return "Profit"
        case .itemsSold: return "Items Sold"
        case .averageSalePrice: return "Average Sale Price"
        case .topCategories: return "Top Categories"
        case .topBrands: return "Top Brands"
        case .customFormula: return "Custom Formula"
        }
    }
}

// MARK: - Configuration Helpers

extension UserWidget {
    /// Decodes the configuration data for this widget
    func getConfiguration<T: WidgetConfiguration>() -> T? {
        guard let configData = configuration else { return nil }
        return try? JSONDecoder().decode(T.self, from: configData)
    }

    /// Encodes and sets the configuration for this widget
    mutating func setConfiguration<T: WidgetConfiguration>(_ config: T) throws {
        self.configuration = try JSONEncoder().encode(config)
    }
}
