import Foundation

/// Shared layout constants for consistent spacing and sizing across the application
///
/// These constants ensure visual consistency between Dashboard, Analytics, and other major views.
/// All spacing values are in points (pt).
enum LayoutConstants {
    // MARK: - Padding

    /// Horizontal padding from screen edges (28pt)
    /// Used for main content areas on Dashboard and Analytics
    static let horizontalPadding: CGFloat = 28

    /// Compact horizontal padding for nested content (16pt)
    static let horizontalPaddingCompact: CGFloat = 16

    // MARK: - Spacing

    /// Vertical spacing between major sections (24pt)
    /// Used between KPI row, Alerts, Quick Lists, and My Widgets sections
    static let sectionSpacing: CGFloat = 24

    /// Spacing between cards in a grid (16pt)
    /// Used for gap between cards in LazyVGrid and HStack layouts
    static let cardSpacing: CGFloat = 16

    /// Compact spacing for internal card content (12pt)
    static let cardSpacingCompact: CGFloat = 12

    // MARK: - Card Heights

    /// Fixed height for KPI cards (120pt)
    static let kpiCardHeight: CGFloat = 120

    /// Minimum height for priority alerts section (80pt)
    static let alertCardMinHeight: CGFloat = 80

    /// Fixed height for quick list cards (240pt)
    static let quickListCardHeight: CGFloat = 240

    /// Standard height for analytics chart cards (280pt)
    static let analyticsChartCardHeight: CGFloat = 280

    // MARK: - Grid Columns

    /// Minimum width for adaptive grid columns (320pt)
    static let gridColumnMinWidth: CGFloat = 320

    /// Maximum width for adaptive grid columns (500pt)
    static let gridColumnMaxWidth: CGFloat = 500

    /// Minimum width for KPI cards (200pt)
    static let kpiCardMinWidth: CGFloat = 200

    /// Maximum width for KPI cards (400pt)
    static let kpiCardMaxWidth: CGFloat = 400
}
