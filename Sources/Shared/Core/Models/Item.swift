import Foundation

public enum ItemStatus: String, Codable, CaseIterable {
    case inStock = "In Stock"
    case listed = "Listed"
    case sold = "Sold"
    case reserved = "Reserved"
    case archived = "Archived"
    case draft = "Draft"
}

public struct Item: Identifiable, Equatable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var brandId: UUID?
    public var categoryId: UUID?
    public var purchasePrice: Decimal
    public var quantity: Int
    public var dateAdded: Date
    public var condition: String
    public var notes: String?
    public var status: ItemStatus
    public var sku: String?
    public var category: String?  // Added for UI display

    // In-memory convenience, not persisted directly in Item table
    public var images: [ImageAttachment] = []

    public init(
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
