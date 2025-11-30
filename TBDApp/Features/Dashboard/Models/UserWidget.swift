import Foundation

// MARK: - User Widget Model

/// Represents a user-added dashboard widget
///
/// User widgets are customizable dashboard components that users can add, configure,
/// remove, and reorder through the dashboard UI. Each widget has a type (which determines
/// the visualization), a size (small/medium/large), and a position in the grid.
///
/// ## Persistence
/// User widgets are persisted to the database in the `user_dashboard_widget` table.
/// Changes are saved automatically through the `UserWidgetRepository`.
///
/// ## Usage
/// ```swift
/// let widget = UserWidget(
///     type: .revenueChart,
///     size: .large,
///     name: "Monthly Revenue",
///     position: 0
/// )
/// ```
struct UserWidget: Identifiable, Codable, Equatable {
    let id: UUID
    var type: DashboardWidgetType
    var size: DashboardWidgetSize
    var name: String
    var position: Int

    init(
        id: UUID = UUID(),
        type: DashboardWidgetType,
        size: DashboardWidgetSize,
        name: String,
        position: Int
    ) {
        self.id = id
        self.type = type
        self.size = size
        self.name = name
        self.position = position
    }
}
