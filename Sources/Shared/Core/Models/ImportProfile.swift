import Foundation

enum ImportTargetType: String, Codable, CaseIterable {
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

struct FieldMapping: Codable, Equatable {
    var sourceField: String
    var targetField: String  // core field name or customFieldId
    var isCustomField: Bool

    init(sourceField: String, targetField: String, isCustomField: Bool = false) {
        self.sourceField = sourceField
        self.targetField = targetField
        self.isCustomField = isCustomField
    }
}

struct ImportProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var targetType: ImportTargetType
    var mappings: [FieldMapping]
    var createdAt: Date
    var updatedAt: Date

    init(
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
