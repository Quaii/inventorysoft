import Foundation

struct CustomFieldValue: Identifiable, Codable, Equatable {
    let id: UUID
    var customFieldId: UUID
    var entityId: UUID  // itemId, saleId, or purchaseId
    var value: String  // stored as string, parsed based on field type

    init(
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
