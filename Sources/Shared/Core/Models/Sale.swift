import Foundation

public struct Sale: Identifiable, Codable, Equatable {
    public let id: UUID
    public var itemId: UUID
    public var soldPrice: Decimal
    public var platform: String
    public var fees: Decimal
    public var dateSold: Date
    public var buyer: String?

    public init(
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
