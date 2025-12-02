import Foundation

public enum ImportTargetType: String, Codable, CaseIterable {
    case item
    case sale
    case purchase

    public var displayName: String {
        switch self {
        case .item: return "Items"
        case .sale: return "Sales"
        case .purchase: return "Purchases"
        }
    }
}

public struct FieldMapping: Codable, Equatable {
    public var sourceField: String
    public var targetField: String  // core field name or customFieldId
    public var isCustomField: Bool

    public init(sourceField: String, targetField: String, isCustomField: Bool = false) {
        self.sourceField = sourceField
        self.targetField = targetField
        self.isCustomField = isCustomField
    }
}

public struct ImportProfile: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var targetType: ImportTargetType
    public var mappings: [FieldMapping]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        targetType: ImportTargetType,
        mappings: [FieldMapping] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.targetType = targetType
        self.mappings = mappings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
