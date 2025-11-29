import Foundation

struct Sale: Identifiable, Codable {
    let id: UUID
    var itemId: UUID
    var date: Date
    var amount: Decimal
    var platform: String?

    init(
        id: UUID = UUID(), itemId: UUID, date: Date = Date(), amount: Decimal,
        platform: String? = nil
    ) {
        self.id = id
        self.itemId = itemId
        self.date = date
        self.amount = amount
        self.platform = platform
    }
}
