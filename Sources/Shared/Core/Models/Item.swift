import Foundation

enum ItemStatus: String, Codable, CaseIterable {
    case inStock = "In Stock"
    case listed = "Listed"
    case sold = "Sold"
    case reserved = "Reserved"
    case archived = "Archived"
    case draft = "Draft"
}

struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var brandId: UUID?
    var categoryId: UUID?
    var purchasePrice: Decimal
    var quantity: Int
    var dateAdded: Date
    var condition: String
    var notes: String?
    var status: ItemStatus
    var sku: String?
    var category: String?  // Added for UI display

    // In-memory convenience, not persisted directly in Item table
    var images: [ImageAttachment] = []

    init(
        id: UUID = UUID(),
        title: String,
        brandId: UUID? = nil,
        categoryId: UUID? = nil,
        purchasePrice: Decimal = 0,
        quantity: Int = 1,
        dateAdded: Date = Date(),
        condition: String = "New",
        notes: String? = nil,
        status: ItemStatus = .draft,
        sku: String? = nil,
        category: String? = nil,
        images: [ImageAttachment] = []
    ) {
        self.id = id
        self.title = title
        self.brandId = brandId
        self.categoryId = categoryId
        self.purchasePrice = purchasePrice
        self.quantity = quantity
        self.dateAdded = dateAdded
        self.condition = condition
        self.notes = notes
        self.status = status
        self.sku = sku
        self.category = category
        self.images = images
    }
}
