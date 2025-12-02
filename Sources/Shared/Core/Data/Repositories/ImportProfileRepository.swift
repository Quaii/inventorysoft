import Foundation
import GRDB

public protocol ImportProfileRepositoryProtocol {
    func getAllProfiles() async throws -> [ImportProfile]
    func getProfile(id: UUID) async throws -> ImportProfile?
    func getProfiles(for targetType: ImportTargetType) async throws -> [ImportProfile]
    func saveProfile(_ profile: ImportProfile) async throws
    func deleteProfile(id: UUID) async throws
}

public class ImportProfileRepository: ImportProfileRepositoryProtocol {
    private let dbWriter: DatabaseWriter
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    public init(dbWriter: DatabaseWriter = DatabaseManager.shared.dbWriter) {
        self.dbWriter = dbWriter
    }

    public func getAllProfiles() async throws -> [ImportProfile] {
        try await dbWriter.read { [self] db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.ImportProfileTable.databaseTableName)
                    ORDER BY \(SchemaDefinitions.ImportProfileTable.name)
                    """
            ).map { self.profileFromRow($0) }
        }
    }

    public func getProfile(id: UUID) async throws -> ImportProfile? {
        try await dbWriter.read { [self] db in
            if let row = try Row.fetchOne(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.ImportProfileTable.databaseTableName)
                    WHERE \(SchemaDefinitions.ImportProfileTable.id) = ?
                    """,
                arguments: [id.uuidString]
            ) {
                return self.profileFromRow(row)
            }
            return nil
        }
    }

    public func getProfiles(for targetType: ImportTargetType) async throws -> [ImportProfile] {
        try await dbWriter.read { [self] db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT * FROM \(SchemaDefinitions.ImportProfileTable.databaseTableName)
                    WHERE \(SchemaDefinitions.ImportProfileTable.targetType) = ?
                    ORDER BY \(SchemaDefinitions.ImportProfileTable.name)
                    """,
                arguments: [targetType.rawValue]
            ).map { self.profileFromRow($0) }
        }
    }

    public func saveProfile(_ profile: ImportProfile) async throws {
        let mappingsJSON = try jsonEncoder.encode(profile.mappings)
        let mappingsString = String(data: mappingsJSON, encoding: .utf8)!

        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    INSERT OR REPLACE INTO \(SchemaDefinitions.ImportProfileTable.databaseTableName)
                    (\(SchemaDefinitions.ImportProfileTable.id),
                     \(SchemaDefinitions.ImportProfileTable.name),
                     \(SchemaDefinitions.ImportProfileTable.targetType),
                     \(SchemaDefinitions.ImportProfileTable.mappings),
                     \(SchemaDefinitions.ImportProfileTable.createdAt),
                     \(SchemaDefinitions.ImportProfileTable.updatedAt))
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                arguments: [
                    profile.id.uuidString,
                    profile.name,
                    profile.targetType.rawValue,
                    mappingsString,
                    profile.createdAt,
                    profile.updatedAt,
                ]
            )
        }
    }

    public func deleteProfile(id: UUID) async throws {
        try await dbWriter.write { db in
            try db.execute(
                sql: """
                    DELETE FROM \(SchemaDefinitions.ImportProfileTable.databaseTableName)
                    WHERE \(SchemaDefinitions.ImportProfileTable.id) = ?
                    """,
                arguments: [id.uuidString]
            )
        }
    }

    // MARK: - Row Mapping

    private func profileFromRow(_ row: Row) -> ImportProfile {
        let mappingsString: String = row[SchemaDefinitions.ImportProfileTable.mappings]
        let mappingsData = mappingsString.data(using: .utf8)!
        let mappings = try! jsonDecoder.decode([FieldMapping].self, from: mappingsData)

        return ImportProfile(
            id: UUID(uuidString: row[SchemaDefinitions.ImportProfileTable.id])!,
            name: row[SchemaDefinitions.ImportProfileTable.name],
            targetType: ImportTargetType(
                rawValue: row[SchemaDefinitions.ImportProfileTable.targetType])!,
            mappings: mappings,
            createdAt: row[SchemaDefinitions.ImportProfileTable.createdAt],
            updatedAt: row[SchemaDefinitions.ImportProfileTable.updatedAt]
        )
    }
}
