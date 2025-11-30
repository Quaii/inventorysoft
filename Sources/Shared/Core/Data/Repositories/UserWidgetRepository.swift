import Foundation
import GRDB

// MARK: - User Widget Repository Protocol

/// Protocol for managing user dashboard widgets in persistent storage
protocol UserWidgetRepositoryProtocol {
    /// Load all user widgets ordered by position
    func getAllWidgets() async throws -> [UserWidget]

    /// Get a specific widget by ID
    func getWidget(id: UUID) async throws -> UserWidget?

    /// Save a single widget (insert or update)
    func saveWidget(_ widget: UserWidget) async throws

    /// Save multiple widgets (replaces all existing)
    func saveAllWidgets(_ widgets: [UserWidget]) async throws

    /// Delete a widget by ID
    func deleteWidget(id: UUID) async throws

    /// Delete all user widgets
    func deleteAllWidgets() async throws
}

// MARK: - User Widget Repository

/// Repository for persisting user-added dashboard widgets
///
/// This repository manages the `user_dashboard_widget` table which stores
/// user-customized widgets. Supports CRUD operations with async/await.
///
/// ## Database Schema
/// Table: `user_dashboard_widget`
/// - id: UUID (primary key)
/// - name: TEXT
/// - type: TEXT (widget type raw value)
/// - size: TEXT (small/medium/large)
/// - position: INTEGER (sort order)
///
/// ## Error Handling
/// All methods throw `DatabaseError` on failure. Callers should handle:
/// - Connection failures
/// - Constraint violations
/// - Data corruption
class UserWidgetRepository: UserWidgetRepositoryProtocol {
    private let dbWriter: DatabaseWriter

    init(dbWriter: DatabaseWriter = DatabaseManager.shared.dbWriter) {
        self.dbWriter = dbWriter
    }

    // MARK: - CRUD Operations

    func getAllWidgets() async throws -> [UserWidget] {
        try await dbWriter.read { db in
            let rows = try Row.fetchAll(
                db,
                sql: """
                    SELECT id, name, type, size, position, configuration, isVisible
                    FROM user_dashboard_widget
                    ORDER BY position ASC
                    """
            )

            return rows.compactMap { row in
                guard
                    let idString: String = row["id"],
                    let id = UUID(uuidString: idString),
                    let name: String = row["name"],
                    let typeRaw: String = row["type"],
                    let type = DashboardWidgetType(rawValue: typeRaw),
                    let sizeRaw: String = row["size"],
                    let size = DashboardWidgetSize(rawValue: sizeRaw),
                    let position: Int = row["position"]
                else {
                    print("Warning: Failed to parse widget row: \(row)")
                    return nil
                }

                let configuration: Data? = row["configuration"]
                let isVisible: Bool = row["isVisible"] ?? true

                return UserWidget(
                    id: id,
                    type: type,
                    size: size,
                    name: name,
                    position: position,
                    configuration: configuration,
                    isVisible: isVisible
                )
            }
        }
    }

    func getWidget(id: UUID) async throws -> UserWidget? {
        try await dbWriter.read { db in
            guard
                let row = try Row.fetchOne(
                    db,
                    sql: """
                        SELECT id, name, type, size, position, configuration, isVisible
                        FROM user_dashboard_widget
                        WHERE id = ?
                        """,
                    arguments: [id.uuidString]
                )
            else {
                return nil
            }

            guard
                let idString: String = row["id"],
                let widgetId = UUID(uuidString: idString),
                let name: String = row["name"],
                let typeRaw: String = row["type"],
                let type = DashboardWidgetType(rawValue: typeRaw),
                let sizeRaw: String = row["size"],
                let size = DashboardWidgetSize(rawValue: sizeRaw),
                let position: Int = row["position"]
            else {
                return nil
            }

            let configuration: Data? = row["configuration"]
            let isVisible: Bool = row["isVisible"] ?? true

            return UserWidget(
                id: widgetId,
                type: type,
                size: size,
                name: name,
                position: position,
                configuration: configuration,
                isVisible: isVisible
            )
        }
    }

    func saveWidget(_ widget: UserWidget) async throws {
        let now = Date()
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    INSERT OR REPLACE INTO user_dashboard_widget
                    (id, name, type, size, position, configuration, isVisible, createdAt, updatedAt)
                    VALUES (?, ?, ?, ?, ?, ?, ?, COALESCE((SELECT createdAt FROM user_dashboard_widget WHERE id = ?), ?), ?)
                    """,
                arguments: [
                    widget.id.uuidString,
                    widget.name,
                    widget.type.rawValue,
                    widget.size.rawValue,
                    widget.position,
                    widget.configuration,
                    widget.isVisible,
                    widget.id.uuidString,  // For COALESCE to preserve existing createdAt
                    now,  // createdAt for new records
                    now,  // updatedAt always updated
                ]
            )
        }
    }

    func saveAllWidgets(_ widgets: [UserWidget]) async throws {
        let now = Date()
        try await dbWriter.write { db in
            // Delete all existing widgets
            try db.execute(sql: "DELETE FROM user_dashboard_widget")

            // Insert new widgets
            for widget in widgets {
                try db.execute(
                    sql: """
                        INSERT INTO user_dashboard_widget
                        (id, name, type, size, position, configuration, isVisible, createdAt, updatedAt)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                    arguments: [
                        widget.id.uuidString,
                        widget.name,
                        widget.type.rawValue,
                        widget.size.rawValue,
                        widget.position,
                        widget.configuration,
                        widget.isVisible,
                        now,
                        now,
                    ]
                )
            }
        }
    }

    func deleteWidget(id: UUID) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: "DELETE FROM user_dashboard_widget WHERE id = ?",
                arguments: [id.uuidString]
            )
        }
    }

    func deleteAllWidgets() async throws {
        try await dbWriter.write { db in
            try db.execute(sql: "DELETE FROM user_dashboard_widget")
        }
    }
}
