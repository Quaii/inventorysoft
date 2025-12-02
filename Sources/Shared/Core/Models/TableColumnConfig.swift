import CoreGraphics
import Foundation

public enum TableType: String, Codable, CaseIterable {
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

public struct TableColumnConfig: Codable, Identifiable, Equatable {
    public let id: UUID
    public var tableType: TableType
    public var field: String  // either core field name or customFieldId
    public var label: String
    public var width: CGFloat?
    public var sortOrder: Int
    public var isVisible: Bool
    public var isCustomField: Bool

    public init(
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
