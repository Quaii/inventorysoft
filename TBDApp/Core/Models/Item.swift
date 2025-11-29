import Foundation

enum ItemStatus: String, Codable, CaseIterable {
    case inStock = "In Stock"
    case sold = "Sold"
    case pending = "Pending"
    case draft = "Draft"
}

struct Item: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var purchasePrice: Decimal
    var sellingPrice: Decimal?
    var status: ItemStatus
    var brandId: UUID?
    var categoryId: UUID?
    var imageIds: [UUID]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(), title: String, description: String = "", purchasePrice: Decimal = 0,
        sellingPrice: Decimal? = nil, status: ItemStatus = .draft, brandId: UUID? = nil,
        categoryId: UUID? = nil, imageIds: [UUID] = [], createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.purchasePrice = purchasePrice
        self.sellingPrice = sellingPrice
        self.status = status
        self.brandId = brandId
        self.categoryId = categoryId
        self.imageIds = imageIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
