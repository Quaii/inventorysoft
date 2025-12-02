import Foundation

public struct CustomFieldValue: Identifiable, Codable, Equatable {
    public let id: UUID
    public var customFieldId: UUID
    public var entityId: UUID  // itemId, saleId, or purchaseId
    public var value: String  // stored as string, parsed based on field type

    public init(
        id: UUID = UUID(),
        customFieldId: UUID,
        entityId: UUID,
        value: String
    ) {
        self.id = id
        self.customFieldId = customFieldId
        self.entityId = entityId
        self.value = value
    }
}
