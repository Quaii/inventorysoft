import Foundation

struct Sale: Identifiable, Codable, Equatable {
    let id: UUID
    var itemId: UUID
    var soldPrice: Decimal
    var platform: String
    var fees: Decimal
    var dateSold: Date
    var buyer: String?

    init(
        id: UUID = UUID(),
        itemId: UUID,
        soldPrice: Decimal,
        platform: String,
        fees: Decimal = 0,
        dateSold: Date = Date(),
        buyer: String? = nil
    ) {
        self.id = id
        self.itemId = itemId
        self.soldPrice = soldPrice
        self.platform = platform
        self.fees = fees
        self.dateSold = dateSold
        self.buyer = buyer
    }
}
