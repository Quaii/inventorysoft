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
public struct UserWidget: Identifiable, Codable, Equatable {
    public let id: UUID
    public var type: DashboardWidgetType
    public var size: DashboardWidgetSize
    public var name: String
    public var position: Int
    public var configuration: Data?  // JSON-encoded widget configuration
    public var isVisible: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        type: DashboardWidgetType,
        size: DashboardWidgetSize,
        name: String,
        position: Int,
        configuration: Data? = nil,
        isVisible: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.size = size
        self.name = name
        self.position = position
        self.configuration = configuration
        self.isVisible = isVisible
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
