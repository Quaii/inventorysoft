import Foundation
import GRDB

protocol CustomFieldRepositoryProtocol {
    func getAllDefinitions() async throws -> [CustomFieldDefinition]
    func getDefinitions(for appliesTo: CustomFieldAppliesTo) async throws -> [CustomFieldDefinition]
    func getDefinition(id: UUID) async throws -> CustomFieldDefinition?
    func createDefinition(_ definition: CustomFieldDefinition) async throws
    func updateDefinition(_ definition: CustomFieldDefinition) async throws
    func deleteDefinition(id: UUID) async throws

    func getValue(customFieldId: UUID, entityId: UUID) async throws -> CustomFieldValue?
    func getValues(for entityId: UUID) async throws -> [CustomFieldValue]
    func setValue(_ value: CustomFieldValue) async throws
    func deleteValues(for entityId: UUID) async throws
}

class CustomFieldRepository: CustomFieldRepositoryProtocol {
    private let dbWriter: DatabaseWriter

    init(dbWriter: DatabaseWriter = DatabaseManager.shared.dbWriter) {
        self.dbWriter = dbWriter
    }

    // MARK: - Field Definitions

    func getAllDefinitions() async throws -> [CustomFieldDefinition] {
        try await dbWriter.read { [self] db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName)
                    ORDER BY \(SchemaDefinitions.CustomFieldDefinitionTable.sortOrder)
                    """
            ).map { self.customFieldDefinitionFromRow($0) }
        }
    }

    func getDefinitions(for appliesTo: CustomFieldAppliesTo) async throws -> [CustomFieldDefinition]
    {
        try await dbWriter.read { [self] db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName)
                    WHERE \(SchemaDefinitions.CustomFieldDefinitionTable.appliesTo) = ?
                    ORDER BY \(SchemaDefinitions.CustomFieldDefinitionTable.sortOrder)
                    """,
                arguments: [appliesTo.rawValue]
            ).map { self.customFieldDefinitionFromRow($0) }
        }
    }

    func getDefinition(id: UUID) async throws -> CustomFieldDefinition? {
        try await dbWriter.read { [self] db in
            if let row = try Row.fetchOne(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName)
                    WHERE \(SchemaDefinitions.CustomFieldDefinitionTable.id) = ?
                    """,
                arguments: [id.uuidString]
            ) {
                return self.customFieldDefinitionFromRow(row)
            }
            return nil
        }
    }

    func createDefinition(_ definition: CustomFieldDefinition) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    INSERT INTO \(SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName)
                    (\(SchemaDefinitions.CustomFieldDefinitionTable.id),
                     \(SchemaDefinitions.CustomFieldDefinitionTable.name),
                     \(SchemaDefinitions.CustomFieldDefinitionTable.type),
                     \(SchemaDefinitions.CustomFieldDefinitionTable.appliesTo),
                     \(SchemaDefinitions.CustomFieldDefinitionTable.selectOptions),
                     \(SchemaDefinitions.CustomFieldDefinitionTable.isRequired),
                     \(SchemaDefinitions.CustomFieldDefinitionTable.sortOrder),
                     \(SchemaDefinitions.CustomFieldDefinitionTable.createdAt))
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                arguments: [
                    definition.id.uuidString,
                    definition.name,
                    definition.type.rawValue,
                    definition.appliesTo.rawValue,
                    definition.selectOptions?.joined(separator: ","),
                    definition.isRequired,
                    definition.sortOrder,
                    definition.createdAt,
                ]
            )
        }
    }

    func updateDefinition(_ definition: CustomFieldDefinition) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    UPDATE \(SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName)
                    SET \(SchemaDefinitions.CustomFieldDefinitionTable.name) = ?,
                        \(SchemaDefinitions.CustomFieldDefinitionTable.type) = ?,
                        \(SchemaDefinitions.CustomFieldDefinitionTable.selectOptions) = ?,
                        \(SchemaDefinitions.CustomFieldDefinitionTable.isRequired) = ?,
                        \(SchemaDefinitions.CustomFieldDefinitionTable.sortOrder) = ?
                    WHERE \(SchemaDefinitions.CustomFieldDefinitionTable.id) = ?
                    """,
                arguments: [
                    definition.name,
                    definition.type.rawValue,
                    definition.selectOptions?.joined(separator: ","),
                    definition.isRequired,
                    definition.sortOrder,
                    definition.id.uuidString,
                ]
            )
        }
    }

    func deleteDefinition(id: UUID) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    DELETE FROM \(SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName)
                    WHERE \(SchemaDefinitions.CustomFieldDefinitionTable.id) = ?
                    """,
                arguments: [id.uuidString]
            )
        }
    }

    // MARK: - Field Values

    func getValue(customFieldId: UUID, entityId: UUID) async throws -> CustomFieldValue? {
        try await dbWriter.read { [self] db in
            if let row = try Row.fetchOne(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.CustomFieldValueTable.databaseTableName)
                    WHERE \(SchemaDefinitions.CustomFieldValueTable.customFieldId) = ?
                    AND \(SchemaDefinitions.CustomFieldValueTable.entityId) = ?
                    """,
                arguments: [customFieldId.uuidString, entityId.uuidString]
            ) {
                return self.customFieldValueFromRow(row)
            }
            return nil
        }
    }

    func getValues(for entityId: UUID) async throws -> [CustomFieldValue] {
        try await dbWriter.read { [self] db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.CustomFieldValueTable.databaseTableName)
                    WHERE \(SchemaDefinitions.CustomFieldValueTable.entityId) = ?
                    """,
                arguments: [entityId.uuidString]
            ).map { self.customFieldValueFromRow($0) }
        }
    }

    func setValue(_ value: CustomFieldValue) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    INSERT OR REPLACE INTO \(SchemaDefinitions.CustomFieldValueTable.databaseTableName)
                    (\(SchemaDefinitions.CustomFieldValueTable.id),
                     \(SchemaDefinitions.CustomFieldValueTable.customFieldId),
                     \(SchemaDefinitions.CustomFieldValueTable.entityId),
                     \(SchemaDefinitions.CustomFieldValueTable.value))
                    VALUES (?, ?, ?, ?)
                    """,
                arguments: [
                    value.id.uuidString,
                    value.customFieldId.uuidString,
                    value.entityId.uuidString,
                    value.value,
                ]
            )
        }
    }

    func deleteValues(for entityId: UUID) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    DELETE FROM \(SchemaDefinitions.CustomFieldValueTable.databaseTableName)
                    WHERE \(SchemaDefinitions.CustomFieldValueTable.entityId) = ?
                    """,
                arguments: [entityId.uuidString]
            )
        }
    }

    // MARK: - Row Mapping

    private func customFieldDefinitionFromRow(_ row: Row) -> CustomFieldDefinition {
        let selectOptionsString: String? = row[
            SchemaDefinitions.CustomFieldDefinitionTable.selectOptions]
        let selectOptions = selectOptionsString?.split(separator: ",").map(String.init)

        return CustomFieldDefinition(
            id: UUID(uuidString: row[SchemaDefinitions.CustomFieldDefinitionTable.id])!,
            name: row[SchemaDefinitions.CustomFieldDefinitionTable.name],
            type: CustomFieldType(
                rawValue: row[SchemaDefinitions.CustomFieldDefinitionTable.type])!,
            appliesTo: CustomFieldAppliesTo(
                rawValue: row[SchemaDefinitions.CustomFieldDefinitionTable.appliesTo])!,
            selectOptions: selectOptions,
            isRequired: row[SchemaDefinitions.CustomFieldDefinitionTable.isRequired],
            sortOrder: row[SchemaDefinitions.CustomFieldDefinitionTable.sortOrder],
            createdAt: row[SchemaDefinitions.CustomFieldDefinitionTable.createdAt]
        )
    }

    private func customFieldValueFromRow(_ row: Row) -> CustomFieldValue {
        CustomFieldValue(
            id: UUID(uuidString: row[SchemaDefinitions.CustomFieldValueTable.id])!,
            customFieldId: UUID(
                uuidString: row[SchemaDefinitions.CustomFieldValueTable.customFieldId])!,
            entityId: UUID(uuidString: row[SchemaDefinitions.CustomFieldValueTable.entityId])!,
            value: row[SchemaDefinitions.CustomFieldValueTable.value]
        )
    }
}
