import Foundation
import SwiftUI

// Grid layout configuration for dashboard widgets and responsive layouts
struct GridLayoutConfig {
    // 12-column responsive grid system
    static let totalColumns = 12

    /// Grid column configuration for adaptive layouts
    static func adaptiveColumns(minWidth: CGFloat = 350) -> [GridItem] {
        [GridItem(.adaptive(minimum: minWidth), spacing: 16)]
    }

    /// Fixed columns for specific layouts
    static func fixedColumns(count: Int, spacing: CGFloat = 16) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }

    /// Widget size to grid columns mapping
    static func columnsForWidgetSize(_ size: WidgetSize) -> Int {
        switch size {
        case .small: return 4  // 1/3 of 12-column grid
        case .medium: return 6  // 1/2 of 12-column grid
        case .large: return 12  // Full width
        }
    }

    /// Calculate GridItem array for a row of widgets
    static func gridItemsForWidgets(_ widgets: [DashboardWidget]) -> [GridItem] {
        // For now, use adaptive layout
        // Future enhancement: calculate based on widget sizes to create optimal layout
        return adaptiveColumns()
    }

    /// Minimum card width for different widget sizes
    static func minWidthForSize(_ size: WidgetSize) -> CGFloat {
        switch size {
        case .small: return 280
        case .medium: return 400
        case .large: return 600
        }
    }
}
