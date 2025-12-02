import Foundation
import UniformTypeIdentifiers

/// Service to handle export operations with customization support
public class ExportService {
    private let db: DatabaseManager
    private let columnConfigService: ColumnConfigServiceProtocol

    public init(db: DatabaseManager, columnConfigService: ColumnConfigServiceProtocol) {
        self.db = db
        self.columnConfigService = columnConfigService
    }

    // MARK: - CSV Export

    func exportItemsToCSV() async throws -> URL {
        let columns = try await columnConfigService.getColumns(for: .inventory)
        let items = try await db.dbWriter.read { db in
            try Item.fetchAll(db)
        }

        let csvContent = generateCSV(items: items, columns: columns)
        return try saveToTemporaryFile(content: csvContent, filename: "inventory_export.csv")
    }

    func exportSalesToCSV() async throws -> URL {
        let columns = try await columnConfigService.getColumns(for: .sales)
        let sales = try await db.dbWriter.read { db in
            try Sale.fetchAll(db)
        }

        let csvContent = generateCSV(sales: sales, columns: columns)
        return try saveToTemporaryFile(content: csvContent, filename: "sales_export.csv")
    }

    func exportPurchasesToCSV() async throws -> URL {
        let columns = try await columnConfigService.getColumns(for: .purchases)
        let purchases = try await db.dbWriter.read { db in
            try Purchase.fetchAll(db)
        }

        let csvContent = generateCSV(purchases: purchases, columns: columns)
        return try saveToTemporaryFile(content: csvContent, filename: "purchases_export.csv")
    }

    // MARK: - JSON Export

    func exportToJSON() async throws -> URL {
        let items = try await db.dbWriter.read { db in
            try Item.fetchAll(db)
        }

        let sales = try await db.dbWriter.read { db in
            try Sale.fetchAll(db)
        }

        let purchases = try await db.dbWriter.read { db in
            try Purchase.fetchAll(db)
        }

        let exportData: [String: Any] = [
            "items": items.map { itemToDictionary($0) },
            "sales": sales.map { saleToDictionary($0) },
            "purchases": purchases.map { purchaseToDictionary($0) },
            "exportDate": ISO8601DateFormatter().string(from: Date()),
        ]

        let jsonData = try JSONSerialization.data(
            withJSONObject: exportData, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""

        return try saveToTemporaryFile(content: jsonString, filename: "inventory_backup.json")
    }

    // MARK: - Helper Methods

    private func generateCSV(items: [Item], columns: [TableColumnConfig]) -> String {
        let visibleColumns = columns.filter { $0.isVisible }.sorted { $0.sortOrder < $1.sortOrder }

        var csv = visibleColumns.map { $0.label }.joined(separator: ",") + "\n"

        for item in items {
            let row = visibleColumns.map { column in
                escapeCSVField(formatItemField(item, field: column.field))
            }.joined(separator: ",")
            csv += row + "\n"
        }

        return csv
    }

    private func generateCSV(sales: [Sale], columns: [TableColumnConfig]) -> String {
        let visibleColumns = columns.filter { $0.isVisible }.sorted { $0.sortOrder < $1.sortOrder }

        var csv = visibleColumns.map { $0.label }.joined(separator: ",") + "\n"

        for sale in sales {
            let row = visibleColumns.map { column in
                escapeCSVField(formatSaleField(sale, field: column.field))
            }.joined(separator: ",")
            csv += row + "\n"
        }

        return csv
    }

    private func generateCSV(purchases: [Purchase], columns: [TableColumnConfig]) -> String {
        let visibleColumns = columns.filter { $0.isVisible }.sorted { $0.sortOrder < $1.sortOrder }

        var csv = visibleColumns.map { $0.label }.joined(separator: ",") + "\n"

        for purchase in purchases {
            let row = visibleColumns.map { column in
                escapeCSVField(formatPurchaseField(purchase, field: column.field))
            }.joined(separator: ",")
            csv += row + "\n"
        }

        return csv
    }

    private func formatItemField(_ item: Item, field: String) -> String {
        switch field {
        case "title": return item.title
        case "sku": return item.sku ?? ""
        case "category": return item.category ?? ""
        case "purchasePrice": return item.purchasePrice.formatted(.number)
        case "quantity": return "\(item.quantity)"
        case "status": return item.status.rawValue
        case "dateAdded": return ISO8601DateFormatter().string(from: item.dateAdded)
        default: return ""
        }
    }

    private func formatSaleField(_ sale: Sale, field: String) -> String {
        switch field {
        case "platform": return sale.platform
        case "soldPrice": return sale.soldPrice.formatted(.number)
        case "fees": return sale.fees.formatted(.number)
        case "buyer": return sale.buyer ?? ""
        case "dateSold": return ISO8601DateFormatter().string(from: sale.dateSold)
        default: return ""
        }
    }

    private func formatPurchaseField(_ purchase: Purchase, field: String) -> String {
        switch field {
        case "batchName": return purchase.batchName ?? ""
        case "supplier": return purchase.supplier
        case "cost": return purchase.cost.formatted(.number)
        case "datePurchased": return ISO8601DateFormatter().string(from: purchase.datePurchased)
        default: return ""
        }
    }

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }

    private func itemToDictionary(_ item: Item) -> [String: Any] {
        [
            "id": item.id.uuidString,
            "title": item.title,
            "sku": item.sku as Any,
            "purchasePrice": item.purchasePrice as Any,
            "quantity": item.quantity,
            "status": item.status.rawValue,
            "dateAdded": ISO8601DateFormatter().string(from: item.dateAdded),
        ]
    }

    private func saleToDictionary(_ sale: Sale) -> [String: Any] {
        [
            "id": sale.id.uuidString,
            "platform": sale.platform,
            "soldPrice": sale.soldPrice,
            "fees": sale.fees as Any,
            "buyer": sale.buyer as Any,
            "dateSold": ISO8601DateFormatter().string(from: sale.dateSold),
        ]
    }

    private func purchaseToDictionary(_ purchase: Purchase) -> [String: Any] {
        [
            "id": purchase.id.uuidString,
            "batchName": purchase.batchName ?? "",
            "supplier": purchase.supplier as Any,
            "cost": purchase.cost,
            "datePurchased": ISO8601DateFormatter().string(from: purchase.datePurchased),
        ]
    }

    private func saveToTemporaryFile(content: String, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}
