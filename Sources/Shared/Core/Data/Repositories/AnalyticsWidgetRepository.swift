import Foundation
import GRDB

// MARK: - Analytics Widget Repository Protocol

/// Repository for managing Analytics page widgets
///
/// Analytics widgets are stored separately from Dashboard widgets to maintain
/// independence between the two features, even though they share the same `UserWidget` model.
protocol AnalyticsWidgetRepositoryProtocol {
    /// Get all Analytics widgets, ordered by position
    func getAllWidgets() async throws -> [UserWidget]

    /// Get a specific widget by ID
    func getWidget(id: UUID) async throws -> UserWidget?

    /// Save a single widget (insert or update)
    func saveWidget(_ widget: UserWidget) async throws

    /// Save multiple widgets at once (e.g., after reordering)
    func saveAllWidgets(_ widgets: [UserWidget]) async throws

    /// Delete a widget by ID
    func deleteWidget(id: UUID) async throws

    /// Delete all Analytics widgets
    func deleteAllWidgets() async throws
}

// MARK: - Analytics Widget Repository Implementation

class AnalyticsWidgetRepository: AnalyticsWidgetRepositoryProtocol {
    private let dbManager: DatabaseManager

    init(dbManager: DatabaseManager = .shared) {
        self.dbManager = dbManager
    }

    func getAllWidgets() async throws -> [UserWidget] {
        try await dbManager.reader.read { db in
            try UserWidget.fetchAll(
                db,
                sql: """
                    SELECT * FROM user_analytics_widget
                    WHERE isVisible = 1
                    ORDER BY position ASC
                    """
            )
        }
    }

    func getWidget(id: UUID) async throws -> UserWidget? {
        try await dbManager.reader.read { db in
            try UserWidget.fetchOne(
                db,
                sql: "SELECT * FROM user_analytics_widget WHERE id = ?",
                arguments: [id.uuidString]
            )
        }
    }

    func saveWidget(_ widget: UserWidget) async throws {
        try await dbManager.dbWriter.write { db in
            var widget = widget
            widget.updatedAt = Date()

            // Check if widget exists
            let exists =
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM user_analytics_widget WHERE id = ?",
                    arguments: [widget.id.uuidString]
                ) ?? 0 > 0

            if exists {
                // Update existing
                try db.execute(
                    sql: """
                        UPDATE user_analytics_widget
                        SET name = ?, type = ?, size = ?, position = ?,
                            configuration = ?, isVisible = ?, updatedAt = ?
                        WHERE id = ?
                        """,
                    arguments: [
                        widget.name,
                        widget.type.rawValue,
                        widget.size.rawValue,
                        widget.position,
                        widget.configuration,
                        widget.isVisible ? 1 : 0,
                        widget.updatedAt,
                        widget.id.uuidString,
                    ]
                )
            } else {
                // Insert new
                try db.execute(
                    sql: """
                        INSERT INTO user_analytics_widget
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
                        widget.isVisible ? 1 : 0,
                        widget.createdAt,
                        widget.updatedAt,
                    ]
                )
            }
        }
    }

    func saveAllWidgets(_ widgets: [UserWidget]) async throws {
        try await dbManager.dbWriter.write { db in
            for var widget in widgets {
                widget.updatedAt = Date()

                try db.execute(
                    sql: """
                        INSERT OR REPLACE INTO user_analytics_widget
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
                        widget.isVisible ? 1 : 0,
                        widget.createdAt,
                        widget.updatedAt,
                    ]
                )
            }
        }
    }

    func deleteWidget(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            try db.execute(
                sql: "DELETE FROM user_analytics_widget WHERE id = ?",
                arguments: [id.uuidString]
            )
        }
    }

    func deleteAllWidgets() async throws {
        try await dbManager.dbWriter.write { db in
            try db.execute(sql: "DELETE FROM user_analytics_widget")
        }
    }
}

// MARK: - UserWidget GRDB Extensions for Analytics

extension UserWidget {
    /// Fetch widgets from a database result set
    static func fetchAll(
        _ db: Database, sql: String, arguments: StatementArguments = StatementArguments()
    ) throws -> [UserWidget] {
        let rows = try Row.fetchAll(db, sql: sql, arguments: arguments)
        return rows.compactMap { row in
            guard
                let idString = row["id"] as? String,
                let id = UUID(uuidString: idString),
                let name = row["name"] as? String,
                let typeString = row["type"] as? String,
                let type = DashboardWidgetType(rawValue: typeString),
                let sizeString = row["size"] as? String,
                let size = DashboardWidgetSize(rawValue: sizeString),
                let position = row["position"] as? Int,
                let isVisibleInt = row["isVisible"] as? Int,
                let createdAtString = row["createdAt"] as? String,
                let updatedAtString = row["updatedAt"] as? String,
                let createdAt = ISO8601DateFormatter().date(from: createdAtString),
                let updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
            else {
                return nil
            }

            let configuration = row["configuration"] as? Data

            return UserWidget(
                id: id,
                type: type,
                size: size,
                name: name,
                position: position,
                configuration: configuration,
                isVisible: isVisibleInt == 1,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        }
    }

    /// Fetch a single widget
    static func fetchOne(
        _ db: Database, sql: String, arguments: StatementArguments = StatementArguments()
    ) throws -> UserWidget? {
        guard let row = try Row.fetchOne(db, sql: sql, arguments: arguments) else {
            return nil
        }

        guard
            let idString = row["id"] as? String,
            let id = UUID(uuidString: idString),
            let name = row["name"] as? String,
            let typeString = row["type"] as? String,
            let type = DashboardWidgetType(rawValue: typeString),
            let sizeString = row["size"] as? String,
            let size = DashboardWidgetSize(rawValue: sizeString),
            let position = row["position"] as? Int,
            let isVisibleInt = row["isVisible"] as? Int,
            let createdAtString = row["createdAt"] as? String,
            let updatedAtString = row["updatedAt"] as? String,
            let createdAt = ISO8601DateFormatter().date(from: createdAtString),
            let updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
        else {
            return nil
        }

        let configuration = row["configuration"] as? Data

        return UserWidget(
            id: id,
            type: type,
            size: size,
            name: name,
            position: position,
            configuration: configuration,
            isVisible: isVisibleInt == 1,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
