import Foundation

struct Purchase: Identifiable, Codable {
    let id: UUID
    var itemId: UUID
    var date: Date
    var amount: Decimal
    var source: String?

    init(
        id: UUID = UUID(), itemId: UUID, date: Date = Date(), amount: Decimal, source: String? = nil
    ) {
        self.id = id
        self.itemId = itemId
        self.date = date
        self.amount = amount
        self.source = source
    }
}
