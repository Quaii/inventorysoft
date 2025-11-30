import CoreGraphics
import Foundation

enum TableType: String, Codable, CaseIterable {
    case inventory
    case sales
    case purchases

    var displayName: String {
        switch self {
        case .inventory: return "Inventory"
        case .sales: return "Sales"
        case .purchases: return "Purchases"
        }
    }
}

struct TableColumnConfig: Identifiable, Codable, Equatable {
    let id: UUID
    var tableType: TableType
    var field: String  // either core field name or customFieldId
    var label: String
    var width: CGFloat?
    var sortOrder: Int
    var isVisible: Bool
    var isCustomField: Bool

    init(
        id: UUID = UUID(),
        tableType: TableType,
        field: String,
        label: String,
        width: CGFloat? = nil,
        sortOrder: Int,
        isVisible: Bool = true,
        isCustomField: Bool = false
    ) {
        self.id = id
        self.tableType = tableType
        self.field = field
        self.label = label
        self.width = width
        self.sortOrder = sortOrder
        self.isVisible = isVisible
        self.isCustomField = isCustomField
    }
}
