import Foundation
import GRDB

public protocol DashboardConfigRepositoryProtocol {
    func getAllWidgets() async throws -> [DashboardWidget]
    func getWidget(id: UUID) async throws -> DashboardWidget?
    func saveWidget(_ widget: DashboardWidget) async throws
    func deleteWidget(id: UUID) async throws
    func saveAllWidgets(_ widgets: [DashboardWidget]) async throws
}

public class DashboardConfigRepository: DashboardConfigRepositoryProtocol {
    private let dbWriter: DatabaseWriter

    public init(dbWriter: DatabaseWriter = DatabaseManager.shared.dbWriter) {
        self.dbWriter = dbWriter
    }

    public func getAllWidgets() async throws -> [DashboardWidget] {
        try await dbWriter.read { [self] db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.DashboardWidgetTable.databaseTableName)
                    ORDER BY \(SchemaDefinitions.DashboardWidgetTable.sortOrder)
                    """
            ).map(mapRowToWidget)
        }
    }

    public func getWidget(id: UUID) async throws -> DashboardWidget? {
        try await dbWriter.read { [self] db in
            if let row = try Row.fetchOne(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.DashboardWidgetTable.databaseTableName)
                    WHERE \(SchemaDefinitions.DashboardWidgetTable.id) = ?
                    """,
                arguments: [id.uuidString]
            ) {
                return self.mapRowToWidget(row)
            }
            return nil
        }
    }

    public func saveWidget(_ widget: DashboardWidget) async throws {
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
                    widget.position.col,
                    widget.chartType?.rawValue,
                    widget.isVisible,
                    widget.sortOrder,
                ]
            )
        }
    }

    public func deleteWidget(id: UUID) async throws {
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

    public func saveAllWidgets(_ widgets: [DashboardWidget]) async throws {
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
                        widget.chartType?.rawValue,
                        widget.isVisible,
                        widget.sortOrder,
                    ]
                )
            }
        }
    }

    // MARK: - Row Mapping

    private func mapRowToWidget(_ row: Row) -> DashboardWidget {
        // Safely unwrap enums with defaults to handle potential database mismatches (e.g. "kpi" vs "stat")
        let metricRaw: String = row[SchemaDefinitions.DashboardWidgetTable.metric]
        let typeRaw: String = row[SchemaDefinitions.DashboardWidgetTable.type]
        let sizeRaw: String = row[SchemaDefinitions.DashboardWidgetTable.size]

        // Handle legacy "kpi" type by mapping it to "stat"
        let effectiveTypeRaw = typeRaw == "kpi" ? "stat" : typeRaw

        return DashboardWidget(
            id: UUID(uuidString: row[SchemaDefinitions.DashboardWidgetTable.id]) ?? UUID(),
            metric: DashboardMetric(rawValue: metricRaw) ?? .totalItems,
            type: WidgetType(rawValue: effectiveTypeRaw) ?? .stat,
            size: WidgetSize(rawValue: sizeRaw) ?? .medium,
            isVisible: row[SchemaDefinitions.DashboardWidgetTable.isVisible],
            sortOrder: row[SchemaDefinitions.DashboardWidgetTable.sortOrder],
            chartType: row[SchemaDefinitions.DashboardWidgetTable.chartType] != nil
                ? ChartType(rawValue: row[SchemaDefinitions.DashboardWidgetTable.chartType]) : nil,
            position: WidgetPosition(
                row: row[SchemaDefinitions.DashboardWidgetTable.positionRow],
                col: row[SchemaDefinitions.DashboardWidgetTable.positionCol]
            )
        )
    }
}
