import SwiftUI

// MARK: - Dashboard Widget Types

/// Defines the available widget types for the dashboard
///
/// Each widget type represents a different visualization or metric that can be displayed
/// on the dashboard. Widget types determine the default configuration, icon, and behavior.
///
/// ## Available Types
/// - `revenueChart`: Line/bar chart showing revenue trends over time
/// - `profitChart`: Chart displaying profit performance and trends
/// - `itemsSoldOverTime`: Sales volume visualization
/// - `topCategories`: Ranking of best-selling product categories
/// - `topBrands`: Top-performing brand leaderboard
/// - `averageSalePrice`: Average pricing metrics over time
/// - `customFormula`: User-defined custom calculations
///
/// ## Usage
/// ```swift
/// let widget = UserWidget(
///     type: .revenueChart,
///     size: .large,
///     name: "Monthly Revenue"
/// )
/// ```
///
/// ## Adding New Widget Types
/// To add a new widget type:
/// 1. Add case to this enum with snake_case rawValue
/// 2. Implement `displayName` for UI display
/// 3. Implement `description` for help text
/// 4. Choose appropriate SF Symbol for `icon`
/// 5. Set sensible `defaultSize` (.small/.medium/.large)
/// 6. Update `AddWidgetModal` if special configuration needed
/// 7. Implement data fetching in `DashboardViewModel` if required
public enum DashboardWidgetType: String, Codable, CaseIterable {
    // KPI Widgets (single metric cards)
    case kpiInventoryValue = "kpi_inventory_value"
    case kpiItemsInStock = "kpi_items_in_stock"
    case kpiItemsListed = "kpi_items_listed"
    case kpiSoldMonth = "kpi_sold_month"
    case kpiRevenueMonth = "kpi_revenue_month"
    case kpiProfitMonth = "kpi_profit_month"

    // Quick List Widgets
    case quickListSales = "quick_list_sales"
    case quickListPurchases = "quick_list_purchases"
    case quickListItems = "quick_list_items"

    // Alert Widgets
    case priorityAlerts = "priority_alerts"

    // Chart Widgets (existing)
    case revenueChart = "revenue_chart"
    case profitChart = "profit_chart"
    case itemsSoldOverTime = "items_sold_over_time"
    case topCategories = "top_categories"
    case topBrands = "top_brands"
    case averageSalePrice = "average_sale_price"
    case customFormula = "custom_formula"

    /// Human-readable name displayed in UI
    public var displayName: String {
        switch self {
        // KPI Widgets
        case .kpiInventoryValue: return "Inventory Value"
        case .kpiItemsInStock: return "Items in Stock"
        case .kpiItemsListed: return "Items Listed"
        case .kpiSoldMonth: return "Sold This Month"
        case .kpiRevenueMonth: return "Revenue (Month)"
        case .kpiProfitMonth: return "Profit (Month)"

        // Quick List Widgets
        case .quickListSales: return "Recent Sales"
        case .quickListPurchases: return "Recent Purchases"
        case .quickListItems: return "Recent Items"

        // Alert Widgets
        case .priorityAlerts: return "Priority Alerts"

        // Chart Widgets
        case .revenueChart: return "Revenue Chart"
        case .profitChart: return "Profit Chart"
        case .itemsSoldOverTime: return "Items Sold Over Time"
        case .topCategories: return "Top Categories"
        case .topBrands: return "Top Brands"
        case .averageSalePrice: return "Average Sale Price"
        case .customFormula: return "Custom Formula"
        }
    }

    /// Description shown in Add Widget modal
    public var description: String {
        switch self {
        // KPI Widgets
        case .kpiInventoryValue: return "Total value of your inventory"
        case .kpiItemsInStock: return "Number of items currently in stock"
        case .kpiItemsListed: return "Items listed for sale"
        case .kpiSoldMonth: return "Items sold this month"
        case .kpiRevenueMonth: return "Revenue generated this month"
        case .kpiProfitMonth: return "Profit earned this month"

        // Quick List Widgets
        case .quickListSales: return "Your most recent sales"
        case .quickListPurchases: return "Your most recent purchases"
        case .quickListItems: return "Recently added inventory items"

        // Alert Widgets
        case .priorityAlerts: return "Important notifications and warnings"

        // Chart Widgets
        case .revenueChart: return "Track revenue trends over time"
        case .profitChart: return "Monitor profit performance"
        case .itemsSoldOverTime: return "View sales volume trends"
        case .topCategories: return "See your best-selling categories"
        case .topBrands: return "Identify top-performing brands"
        case .averageSalePrice: return "Track average selling price"
        case .customFormula: return "Create custom metrics"
        }
    }

    /// SF Symbol icon representing this widget type
    public var icon: String {
        switch self {
        // KPI Widgets
        case .kpiInventoryValue: return "dollarsign.circle"
        case .kpiItemsInStock: return "shippingbox"
        case .kpiItemsListed: return "list.bullet.clipboard"
        case .kpiSoldMonth: return "cart"
        case .kpiRevenueMonth: return "banknote"
        case .kpiProfitMonth: return "chart.line.uptrend.xyaxis"

        // Quick List Widgets
        case .quickListSales: return "cart.fill"
        case .quickListPurchases: return "bag.fill"
        case .quickListItems: return "shippingbox.fill"

        // Alert Widgets
        case .priorityAlerts: return "exclamationmark.triangle.fill"

        // Chart Widgets
        case .revenueChart: return "chart.line.uptrend.xyaxis"
        case .profitChart: return "dollarsign.circle"
        case .itemsSoldOverTime: return "cart.fill"
        case .topCategories: return "square.grid.2x2"
        case .topBrands: return "star.fill"
        case .averageSalePrice: return "chart.bar"
        case .customFormula: return "function"
        }
    }

    /// Default size when widget is first added
    public var defaultSize: DashboardWidgetSize {
        switch self {
        // KPI Widgets - small by default (fit 3 per row)
        case .kpiInventoryValue, .kpiItemsInStock, .kpiItemsListed,
            .kpiSoldMonth, .kpiRevenueMonth, .kpiProfitMonth:
            return .small

        // Quick List Widgets - medium (fit 2 per row, or 1.5 for 3 total)
        case .quickListSales, .quickListPurchases, .quickListItems:
            return .medium

        // Alert Widgets - large (full width)
        case .priorityAlerts:
            return .large

        // Chart Widgets - large for time series, medium for rankings
        case .revenueChart, .profitChart, .itemsSoldOverTime:
            return .large
        case .topCategories, .topBrands:
            return .medium
        case .averageSalePrice, .customFormula:
            return .small
        }
    }

    /// Widget category for grouping in Add Widget modal
    public var category: WidgetCategory {
        switch self {
        case .kpiInventoryValue, .kpiItemsInStock, .kpiItemsListed,
            .kpiSoldMonth, .kpiRevenueMonth, .kpiProfitMonth:
            return .metrics
        case .quickListSales, .quickListPurchases, .quickListItems:
            return .activity
        case .priorityAlerts:
            return .alerts
        case .revenueChart, .profitChart, .itemsSoldOverTime,
            .topCategories, .topBrands, .averageSalePrice, .customFormula:
            return .charts
        }
    }

    /// Maps KPI widget types to their corresponding metric type
    public var kpiMetricType: KPIMetricType? {
        switch self {
        case .kpiInventoryValue: return .inventoryValue
        case .kpiItemsInStock: return .itemsInStock
        case .kpiItemsListed: return .itemsListed
        case .kpiSoldMonth: return .itemsSoldMonth
        case .kpiRevenueMonth: return .revenueMonth
        case .kpiProfitMonth: return .profitMonth
        default: return nil
        }
    }
}

/// Categories for grouping widgets in the Add Widget modal
public enum WidgetCategory: String, CaseIterable {
    case metrics = "Metrics"
    case activity = "Activity"
    case alerts = "Alerts"
    case charts = "Charts"

    public var displayName: String { rawValue }

    public var icon: String {
        switch self {
        case .metrics: return "chart.bar.fill"
        case .activity: return "clock.fill"
        case .alerts: return "bell.fill"
        case .charts: return "chart.xyaxis.line"
        }
    }
}

// MARK: - Dashboard Widget Size

/// Size options for dashboard widgets
///
/// Controls how much space a widget occupies in the grid layout.
/// Sizes directly map to column spans in the 3-column grid system.
///
/// ## Grid Layout
/// - Small: 1 column (33% width)
/// - Medium: 2 columns (66% width)
/// - Large: 3 columns (100% width)
///
/// In edit mode, widgets display in a single-column list layout regardless of size,
/// but return to their configured size when exiting edit mode.
public enum DashboardWidgetSize: String, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"

    /// Capitalized name for UI display
    public var displayName: String {
        rawValue.capitalized
    }

    /// Number of columns this widget spans in the grid (1-3)
    public var columnSpan: Int {
        switch self {
        case .small: return 1
        case .medium: return 2
        case .large: return 3
        }
    }
}
