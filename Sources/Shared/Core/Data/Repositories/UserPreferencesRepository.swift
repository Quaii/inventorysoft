import Foundation
import GRDB

public protocol UserPreferencesRepositoryProtocol {
    func getPreferences() async throws -> UserPreferences
    func savePreferences(_ preferences: UserPreferences) async throws
}

public class UserPreferencesRepository: UserPreferencesRepositoryProtocol {
    private let dbWriter: DatabaseWriter
    private let preferencesId = "default"  // Single row for user preferences

    public init(dbWriter: DatabaseWriter = DatabaseManager.shared.dbWriter) {
        self.dbWriter = dbWriter
    }

    public func getPreferences() async throws -> UserPreferences {
        do {
            return try await self.dbWriter.read { [self] db in
                if let row = try Row.fetchOne(
                    db, sql: "SELECT * FROM userPreferences WHERE id = ?",
                    arguments: [self.preferencesId])
                {
                    return self.userPreferencesFromRow(row)
                }
                // Return default preferences if none exist
                return UserPreferences.default
            }
        }
    }

    public func savePreferences(_ preferences: UserPreferences) async throws {
        try await self.dbWriter.write { [self] db in
            try db.execute(
                sql: """
                    INSERT OR REPLACE INTO userPreferences (
                        id, baseCurrency, displayCurrency, dateFormat, numberFormattingLocale, firstDayOfWeek,
                        themeMode, compactMode, accentColor, sidebarCollapseBehavior,
                        dashboardInitialLayout, allowDashboardEditing, defaultAnalyticsRange, defaultAnalyticsInterval,
                        backupLocationPath, backupFrequency
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                arguments: [
                    preferencesId,
                    preferences.baseCurrency,
                    preferences.displayCurrency,
                    preferences.dateFormat,
                    preferences.numberFormattingLocale,
                    preferences.firstDayOfWeek,
                    preferences.themeMode,
                    preferences.compactMode,
                    preferences.accentColor,
                    preferences.sidebarCollapseBehavior,
                    preferences.dashboardInitialLayout,
                    preferences.allowDashboardEditing,
                    preferences.defaultAnalyticsRange,
                    preferences.defaultAnalyticsInterval,
                    preferences.backupLocationPath,
                    preferences.backupFrequency,
                ]
            )
        }
    }

    // MARK: - Row Mapping

    private func userPreferencesFromRow(_ row: Row) -> UserPreferences {
        UserPreferences(
            baseCurrency: row[SchemaDefinitions.UserPreferencesTable.baseCurrency],
            displayCurrency: row[SchemaDefinitions.UserPreferencesTable.displayCurrency],
            dateFormat: row[SchemaDefinitions.UserPreferencesTable.dateFormat],
            numberFormattingLocale: row[
                SchemaDefinitions.UserPreferencesTable.numberFormattingLocale] ?? "System",
            firstDayOfWeek: row[SchemaDefinitions.UserPreferencesTable.firstDayOfWeek],
            themeMode: row[SchemaDefinitions.UserPreferencesTable.themeMode],
            compactMode: row[SchemaDefinitions.UserPreferencesTable.compactMode],
            accentColor: row[SchemaDefinitions.UserPreferencesTable.accentColor],
            sidebarCollapseBehavior: row[
                SchemaDefinitions.UserPreferencesTable.sidebarCollapseBehavior] ?? "Collapsible",
            dashboardInitialLayout: row[
                SchemaDefinitions.UserPreferencesTable.dashboardInitialLayout]
                ?? "Recommended KPIs",
            allowDashboardEditing: row[SchemaDefinitions.UserPreferencesTable.allowDashboardEditing]
                ?? true,
            defaultAnalyticsRange: row[SchemaDefinitions.UserPreferencesTable.defaultAnalyticsRange]
                ?? "Last 30 Days",
            defaultAnalyticsInterval: row[
                SchemaDefinitions.UserPreferencesTable.defaultAnalyticsInterval] ?? "Daily",
            backupLocationPath: row[SchemaDefinitions.UserPreferencesTable.backupLocationPath]
                ?? "",
            backupFrequency: row[SchemaDefinitions.UserPreferencesTable.backupFrequency] ?? "Off"
        )
    }
}
