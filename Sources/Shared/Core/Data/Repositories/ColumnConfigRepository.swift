import Foundation
import GRDB

public protocol ColumnConfigRepositoryProtocol {
    func getColumns(for tableType: TableType) async throws -> [TableColumnConfig]
    func saveColumn(_ column: TableColumnConfig) async throws
    func saveAllColumns(_ columns: [TableColumnConfig], for tableType: TableType) async throws
    func deleteColumn(id: UUID) async throws
}

public class ColumnConfigRepository: ColumnConfigRepositoryProtocol {
    private let dbWriter: DatabaseWriter

    public init(dbWriter: DatabaseWriter = DatabaseManager.shared.dbWriter) {
        self.dbWriter = dbWriter
    }

    public func getColumns(for tableType: TableType) async throws -> [TableColumnConfig] {
        try await dbWriter.read { [self] db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.TableColumnConfigTable.databaseTableName)
                    WHERE \(SchemaDefinitions.TableColumnConfigTable.tableType) = ?
                    ORDER BY \(SchemaDefinitions.TableColumnConfigTable.sortOrder)
                    """,
                arguments: [tableType.rawValue]
            ).map(self.columnFromRow)
        }
    }

    public func saveColumn(_ column: TableColumnConfig) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    INSERT OR REPLACE INTO \(SchemaDefinitions.TableColumnConfigTable.databaseTableName)
                    (\(SchemaDefinitions.TableColumnConfigTable.id),
                     \(SchemaDefinitions.TableColumnConfigTable.tableType),
                     \(SchemaDefinitions.TableColumnConfigTable.field),
                     \(SchemaDefinitions.TableColumnConfigTable.label),
                     \(SchemaDefinitions.TableColumnConfigTable.width),
                     \(SchemaDefinitions.TableColumnConfigTable.sortOrder),
                     \(SchemaDefinitions.TableColumnConfigTable.isVisible),
                     \(SchemaDefinitions.TableColumnConfigTable.isCustomField))
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                arguments: [
                    column.id.uuidString,
                    column.tableType.rawValue,
                    column.field,
                    column.label,
                    column.width,
                    column.sortOrder,
                    column.isVisible,
                    column.isCustomField,
                ]
            )
        }
    }

    public func saveAllColumns(_ columns: [TableColumnConfig], for tableType: TableType)
        async throws
    {
        try await dbWriter.write { db in
            // Delete existing columns for this table type
            try db.execute(
                sql: """
                    DELETE FROM \(SchemaDefinitions.TableColumnConfigTable.databaseTableName)
                    WHERE \(SchemaDefinitions.TableColumnConfigTable.tableType) = ?
                    """,
                arguments: [tableType.rawValue]
            )

            // Insert all new columns
            for column in columns {
                try db.execute(
                    sql: """
                        INSERT INTO \(SchemaDefinitions.TableColumnConfigTable.databaseTableName)
                        (\(SchemaDefinitions.TableColumnConfigTable.id),
                         \(SchemaDefinitions.TableColumnConfigTable.tableType),
                         \(SchemaDefinitions.TableColumnConfigTable.field),
                         \(SchemaDefinitions.TableColumnConfigTable.label),
                         \(SchemaDefinitions.TableColumnConfigTable.width),
                         \(SchemaDefinitions.TableColumnConfigTable.sortOrder),
                         \(SchemaDefinitions.TableColumnConfigTable.isVisible),
                         \(SchemaDefinitions.TableColumnConfigTable.isCustomField))
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                    arguments: [
                        column.id.uuidString,
                        column.tableType.rawValue,
                        column.field,
                        column.label,
                        column.width,
                        column.sortOrder,
                        column.isVisible,
                        column.isCustomField,
                    ]
                )
            }
        }
    }

    public func deleteColumn(id: UUID) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    DELETE FROM \(SchemaDefinitions.TableColumnConfigTable.databaseTableName)
                    WHERE \(SchemaDefinitions.TableColumnConfigTable.id) = ?
                    """,
                arguments: [id.uuidString]
            )
        }
    }

    // MARK: - Row Mapping

    private func columnFromRow(_ row: Row) -> TableColumnConfig {
        TableColumnConfig(
            id: UUID(uuidString: row[SchemaDefinitions.TableColumnConfigTable.id])!,
            tableType: TableType(
                rawValue: row[SchemaDefinitions.TableColumnConfigTable.tableType])!,
            field: row[SchemaDefinitions.TableColumnConfigTable.field],
            label: row[SchemaDefinitions.TableColumnConfigTable.label],
            width: row[SchemaDefinitions.TableColumnConfigTable.width],
            sortOrder: row[SchemaDefinitions.TableColumnConfigTable.sortOrder],
            isVisible: row[SchemaDefinitions.TableColumnConfigTable.isVisible],
            isCustomField: row[SchemaDefinitions.TableColumnConfigTable.isCustomField]
        )
    }
}
