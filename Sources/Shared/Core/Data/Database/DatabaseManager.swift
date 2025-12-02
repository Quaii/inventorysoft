import Foundation
import GRDB

public class DatabaseManager {
    public static let shared = DatabaseManager()

    // The database writer (DatabaseQueue or DatabasePool)
    public let dbWriter: DatabaseWriter
    public private(set) var setupError: Error?

    private init() {
        do {
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
            do {
                dbWriter = try DatabaseQueue(path: databaseURL.path, configuration: config)
            } catch {
                print("Database creation failed: \(error). Attempting to recover...")
                // Recovery: Delete and recreate
                try fileManager.removeItem(at: databaseURL)
                dbWriter = try DatabaseQueue(path: databaseURL.path, configuration: config)
            }

            // 4. Run migrations
            try migrator.migrate(dbWriter)

        } catch {
            print("Critical Database Error: \(error)")
            setupError = error
            // Fallback to in-memory database so the app doesn't crash
            // The user will see an empty state, but we should show an error alert
            do {
                dbWriter = try DatabaseQueue()
            } catch {
                fatalError("Failed to create in-memory fallback database: \(error)")
            }
        }
    }

    private var migrator: DatabaseMigrator {
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
