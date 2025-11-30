import Foundation
import GRDB

protocol AnalyticsConfigRepositoryProtocol {
    func fetchCharts() async throws -> [ChartDefinition]
    func saveChart(_ chart: ChartDefinition) async throws
    func deleteChart(_ chart: ChartDefinition) async throws
    func updateChartOrder(_ charts: [ChartDefinition]) async throws
}

class AnalyticsConfigRepository: AnalyticsConfigRepositoryProtocol {
    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func fetchCharts() async throws -> [ChartDefinition] {
        try await dbQueue.read { db in
            try ChartDefinition.fetchAll(db).sorted(by: { $0.sortOrder < $1.sortOrder })
        }
    }

    func saveChart(_ chart: ChartDefinition) async throws {
        try await dbQueue.write { db in
            try chart.save(db)
        }
    }

    func deleteChart(_ chart: ChartDefinition) async throws {
        _ = try await dbQueue.write { db in
            try chart.delete(db)
        }
    }

    func updateChartOrder(_ charts: [ChartDefinition]) async throws {
        try await dbQueue.write { db in
            for chart in charts {
                try chart.save(db)
            }
        }
    }
}

// Extension to make ChartDefinition persistable
extension ChartDefinition: FetchableRecord, PersistableRecord {
    // Define database columns if needed, or rely on Codable
    // For now, we'll assume the table name matches the struct name or we define it
    static let databaseTableName = "chartDefinition"
}
