import Foundation

public struct Purchase: Codable, Identifiable, Equatable {
    public let id: UUID
    public var supplier: String
    public var batchName: String?
    public var datePurchased: Date
    public var cost: Decimal

    public init(
        id: UUID = UUID(),
        supplier: String,
        batchName: String? = nil,
        datePurchased: Date = Date(),
        cost: Decimal
    ) {
        self.id = id
        self.supplier = supplier
        self.batchName = batchName
        self.datePurchased = datePurchased
        self.cost = cost
    }
}
