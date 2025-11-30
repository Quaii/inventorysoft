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
enum DashboardWidgetType: String, Codable, CaseIterable {
    case revenueChart = "revenue_chart"
    case profitChart = "profit_chart"
    case itemsSoldOverTime = "items_sold_over_time"
    case topCategories = "top_categories"
    case topBrands = "top_brands"
    case averageSalePrice = "average_sale_price"
    case customFormula = "custom_formula"

    /// Human-readable name displayed in UI
    var displayName: String {
        switch self {
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
    var description: String {
        switch self {
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
    var icon: String {
        switch self {
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
    var defaultSize: DashboardWidgetSize {
        switch self {
        case .revenueChart, .profitChart, .itemsSoldOverTime:
            return .large  // Charts need more space
        case .topCategories, .topBrands:
            return .medium  // Lists work well at medium size
        case .averageSalePrice, .customFormula:
            return .small  // Single metrics fit in small widgets
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
enum DashboardWidgetSize: String, Codable {
    case small = "small"
    case medium = "medium"
    case large = "large"

    /// Capitalized name for UI display
    var displayName: String {
        rawValue.capitalized
    }

    /// Number of columns this widget spans in the grid (1-3)
    var columnSpan: Int {
        switch self {
        case .small: return 1
        case .medium: return 2
        case .large: return 3
        }
    }
}
