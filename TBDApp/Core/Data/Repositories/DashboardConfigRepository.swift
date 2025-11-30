import Foundation
import GRDB

protocol DashboardConfigRepositoryProtocol {
    func getAllWidgets() async throws -> [DashboardWidget]
    func getWidget(id: UUID) async throws -> DashboardWidget?
    func saveWidget(_ widget: DashboardWidget) async throws
    func deleteWidget(id: UUID) async throws
    func saveAllWidgets(_ widgets: [DashboardWidget]) async throws
}

class DashboardConfigRepository: DashboardConfigRepositoryProtocol {
    private let dbWriter: DatabaseWriter

    init(dbWriter: DatabaseWriter = DatabaseManager.shared.dbWriter) {
        self.dbWriter = dbWriter
    }

    func getAllWidgets() async throws -> [DashboardWidget] {
        try await dbWriter.read { [self] db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.DashboardWidgetTable.databaseTableName)
                    ORDER BY \(SchemaDefinitions.DashboardWidgetTable.sortOrder)
                    """
            ).map(widgetFromRow)
        }
    }

    func getWidget(id: UUID) async throws -> DashboardWidget? {
        try await dbWriter.read { [self] db in
            if let row = try Row.fetchOne(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.DashboardWidgetTable.databaseTableName)
                    WHERE \(SchemaDefinitions.DashboardWidgetTable.id) = ?
                    """,
                arguments: [id.uuidString]
            ) {
                return self.widgetFromRow(row)
            }
            return nil
        }
    }

    func saveWidget(_ widget: DashboardWidget) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    INSERT OR REPLACE INTO \(SchemaDefinitions.DashboardWidgetTable.databaseTableName)
                    (\(SchemaDefinitions.DashboardWidgetTable.id),
                     \(SchemaDefinitions.DashboardWidgetTable.type),
                     \(SchemaDefinitions.DashboardWidgetTable.metric),
                     \(SchemaDefinitions.DashboardWidgetTable.size),
                     \(SchemaDefinitions.DashboardWidgetTable.positionRow),
                     \(SchemaDefinitions.DashboardWidgetTable.positionCol),
                     \(SchemaDefinitions.DashboardWidgetTable.chartType),
                     \(SchemaDefinitions.DashboardWidgetTable.isVisible),
                     \(SchemaDefinitions.DashboardWidgetTable.sortOrder))
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                arguments: [
                    widget.id.uuidString,
                    widget.type.rawValue,
                    widget.metric.rawValue,
                    widget.size.rawValue,
                    widget.position.row,
                    widget.position.col,
                    widget.chartType.rawValue,
                    widget.isVisible,
                    widget.sortOrder,
                ]
            )
        }
    }

    func deleteWidget(id: UUID) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    DELETE FROM \(SchemaDefinitions.DashboardWidgetTable.databaseTableName)
                    WHERE \(SchemaDefinitions.DashboardWidgetTable.id) = ?
                    """,
                arguments: [id.uuidString]
            )
        }
    }

    func saveAllWidgets(_ widgets: [DashboardWidget]) async throws {
        try await dbWriter.write { db in
            // Delete all existing widgets
            try db.execute(
                sql: "DELETE FROM \(SchemaDefinitions.DashboardWidgetTable.databaseTableName)"
            )

            // Insert all new widgets
            for widget in widgets {
                try db.execute(
                    sql: """
                        INSERT INTO \(SchemaDefinitions.DashboardWidgetTable.databaseTableName)
                        (\(SchemaDefinitions.DashboardWidgetTable.id),
                         \(SchemaDefinitions.DashboardWidgetTable.type),
                         \(SchemaDefinitions.DashboardWidgetTable.metric),
                         \(SchemaDefinitions.DashboardWidgetTable.size),
                         \(SchemaDefinitions.DashboardWidgetTable.positionRow),
                         \(SchemaDefinitions.DashboardWidgetTable.positionCol),
                         \(SchemaDefinitions.DashboardWidgetTable.chartType),
                         \(SchemaDefinitions.DashboardWidgetTable.isVisible),
                         \(SchemaDefinitions.DashboardWidgetTable.sortOrder))
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                    arguments: [
                        widget.id.uuidString,
                        widget.type.rawValue,
                        widget.metric.rawValue,
                        widget.size.rawValue,
                        widget.position.row,
                        widget.position.col,
                        widget.chartType.rawValue,
                        widget.isVisible,
                        widget.sortOrder,
                    ]
                )
            }
        }
    }

    // MARK: - Row Mapping

    private func widgetFromRow(_ row: Row) -> DashboardWidget {
        DashboardWidget(
            id: UUID(uuidString: row[SchemaDefinitions.DashboardWidgetTable.id])!,
            type: WidgetType(rawValue: row[SchemaDefinitions.DashboardWidgetTable.type])!,
            metric: WidgetMetric(rawValue: row[SchemaDefinitions.DashboardWidgetTable.metric])!,
            size: WidgetSize(rawValue: row[SchemaDefinitions.DashboardWidgetTable.size])!,
            position: WidgetPosition(
                row: row[SchemaDefinitions.DashboardWidgetTable.positionRow],
                col: row[SchemaDefinitions.DashboardWidgetTable.positionCol]
            ),
            chartType: ChartType(rawValue: row[SchemaDefinitions.DashboardWidgetTable.chartType])!,
            isVisible: row[SchemaDefinitions.DashboardWidgetTable.isVisible],
            sortOrder: row[SchemaDefinitions.DashboardWidgetTable.sortOrder]
        )
    }
}
