import Foundation
import GRDB

public class DatabaseManager {
    public static let shared = DatabaseManager()

    // The database writer (DatabaseQueue or DatabasePool)
    public let dbWriter: DatabaseWriter
    public private(set) var setupError: Error?

    private init() {
        do {
            self.dbWriter = try DatabaseManager.createDatabase()
        } catch {
            print("Critical Database Error: \(error)")
            self.setupError = error
            // Fallback to in-memory database
            do {
                self.dbWriter = try DatabaseQueue()
            } catch {
                fatalError("Failed to create in-memory fallback database: \(error)")
            }
        }
    }

    private static func createDatabase() throws -> DatabaseWriter {
        // 1. Setup database path
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
            create: true)
        let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let databaseURL = directoryURL.appendingPathComponent("db.sqlite")

        // 2. Setup configuration
        var config = Configuration()
        config.prepareDatabase { db in
            db.trace { print($0) }  // Debug logging
        }

        // 3. Create DatabaseQueue
        let writer: DatabaseWriter
        do {
            writer = try DatabaseQueue(path: databaseURL.path, configuration: config)
        } catch {
            print("Database creation failed: \(error). Attempting to recover...")
            // Recovery: Delete and recreate
            try fileManager.removeItem(at: databaseURL)
            writer = try DatabaseQueue(path: databaseURL.path, configuration: config)
        }

        // 4. Run migrations
        try DatabaseManager.migrator.migrate(writer)

        return writer
    }

    private static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
            // Erase the database for fresh start during development if needed
            // migrator.eraseDatabaseOnSchemaChange = true
        #endif

        do {
            try Migrations.register(in: &migrator)
        } catch {
            print("Error registering migrations: \(error)")
        }

        return migrator
    }
}

// MARK: - Database Access
extension DatabaseManager {
    // Helper to access the database reader
    public var reader: DatabaseReader {
        dbWriter
    }
}
