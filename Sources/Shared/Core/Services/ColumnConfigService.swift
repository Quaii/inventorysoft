import CoreGraphics
import Foundation

public protocol ColumnConfigServiceProtocol {
    func getColumns(for tableType: TableType) async throws -> [TableColumnConfig]
    func saveColumnConfiguration(_ columns: [TableColumnConfig], for tableType: TableType)
        async throws
    func getDefaultColumns(for tableType: TableType) -> [TableColumnConfig]
    func initializeDefaultColumns(for tableType: TableType) async throws
    func resetToDefaults(for tableType: TableType) async throws
}

public class ColumnConfigService: ColumnConfigServiceProtocol {
    private let repository: ColumnConfigRepositoryProtocol

    public init(repository: ColumnConfigRepositoryProtocol = ColumnConfigRepository()) {
        self.repository = repository
    }

    public func getColumns(for tableType: TableType) async throws -> [TableColumnConfig] {
        let columns = try await repository.getColumns(for: tableType)

        // If no columns exist, initialize with defaults
        if columns.isEmpty {
            try await initializeDefaultColumns(for: tableType)
            return try await repository.getColumns(for: tableType)
        }

        return columns
    }

    public func saveColumnConfiguration(_ columns: [TableColumnConfig], for tableType: TableType)
        async throws
    {
        try await repository.saveAllColumns(columns, for: tableType)
    }

    public func getDefaultColumns(for tableType: TableType) -> [TableColumnConfig] {
        switch tableType {
        case .inventory:
            return getDefaultInventoryColumns()
        case .sales:
            return getDefaultSalesColumns()
        case .purchases:
            return getDefaultPurchasesColumns()
        }
    }

    public func initializeDefaultColumns(for tableType: TableType) async throws {
        let defaultColumns = getDefaultColumns(for: tableType)
        try await repository.saveAllColumns(defaultColumns, for: tableType)
    }

    public func resetToDefaults(for tableType: TableType) async throws {
        // Clear existing columns and re-initialize with defaults
        try await repository.saveAllColumns([], for: tableType)
        try await initializeDefaultColumns(for: tableType)
    }

    // MARK: - Default Columns

    private func getDefaultInventoryColumns() -> [TableColumnConfig] {
        [
            TableColumnConfig(
                tableType: .inventory, field: "title", label: "Product", sortOrder: 0),
            TableColumnConfig(
                tableType: .inventory, field: "sku", label: "SKU", width: 100, sortOrder: 1),
            TableColumnConfig(
                tableType: .inventory, field: "category", label: "Category", width: 100,
                sortOrder: 2),
            TableColumnConfig(
                tableType: .inventory, field: "purchasePrice", label: "Price", width: 80,
                sortOrder: 3),
            TableColumnConfig(
                tableType: .inventory, field: "quantity", label: "Stock", width: 60, sortOrder: 4),
            TableColumnConfig(
                tableType: .inventory, field: "status", label: "Status", width: 100, sortOrder: 5),
        ]
    }

    private func getDefaultSalesColumns() -> [TableColumnConfig] {
        [
            TableColumnConfig(tableType: .sales, field: "itemTitle", label: "Item", sortOrder: 0),
            TableColumnConfig(
                tableType: .sales, field: "platform", label: "Platform", width: 100, sortOrder: 1),
            TableColumnConfig(
                tableType: .sales, field: "soldPrice", label: "Price", width: 80, sortOrder: 2),
            TableColumnConfig(
                tableType: .sales, field: "fees", label: "Fees", width: 80, sortOrder: 3),
            TableColumnConfig(
                tableType: .sales, field: "profit", label: "Profit", width: 80, sortOrder: 4),
            TableColumnConfig(
                tableType: .sales, field: "dateSold", label: "Date Sold", width: 100, sortOrder: 5),
        ]
    }

    private func getDefaultPurchasesColumns() -> [TableColumnConfig] {
        [
            TableColumnConfig(
                tableType: .purchases, field: "batchName", label: "Batch", sortOrder: 0),
            TableColumnConfig(
                tableType: .purchases, field: "supplier", label: "Supplier", width: 120,
                sortOrder: 1),
            TableColumnConfig(
                tableType: .purchases, field: "cost", label: "Cost", width: 80, sortOrder: 2),
            TableColumnConfig(
                tableType: .purchases, field: "datePurchased", label: "Date", width: 100,
                sortOrder: 3),
        ]
    }
}
