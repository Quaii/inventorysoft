import Foundation

public enum CustomFieldType: String, Codable, CaseIterable {
    case text
    case number
    case date
    case boolean
    case select

    var icon: String {
        switch self {
        case .text: return "textformat"
        case .number: return "number"
        case .date: return "calendar"
        case .boolean: return "checkmark.circle"
        case .select: return "list.bullet"
        }
    }

    var displayName: String {
        switch self {
        case .text: return "Text"
        case .number: return "Number"
        case .date: return "Date"
        case .boolean: return "Yes/No"
        case .select: return "Dropdown"
        }
    }
}

public enum CustomFieldAppliesTo: String, Codable, CaseIterable {
    case item
    case sale
    case purchase

    var displayName: String {
        switch self {
        case .item: return "Items"
        case .sale: return "Sales"
        case .purchase: return "Purchases"
        }
    }
}

public struct CustomFieldDefinition: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var type: CustomFieldType
    public var appliesTo: CustomFieldAppliesTo
    public var selectOptions: [String]?
    public var isRequired: Bool
    public var sortOrder: Int
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        type: CustomFieldType,
        appliesTo: CustomFieldAppliesTo,
        selectOptions: [String]? = nil,
        isRequired: Bool = false,
        sortOrder: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.appliesTo = appliesTo
        self.selectOptions = selectOptions
        self.isRequired = isRequired
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}
