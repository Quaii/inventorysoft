import Foundation

struct Purchase: Identifiable, Codable, Equatable {
    let id: UUID
    var supplier: String
    var batchName: String?
    var datePurchased: Date
    var cost: Decimal

    init(
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
