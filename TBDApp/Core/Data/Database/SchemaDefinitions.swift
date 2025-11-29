import Foundation
import GRDB

struct SchemaDefinitions {
    struct ItemTable {
        static let databaseTableName = "item"
        static let id = "id"
        static let title = "title"
        static let brandId = "brandId"
        static let categoryId = "categoryId"
        static let purchasePrice = "purchasePrice"
        static let quantity = "quantity"
        static let dateAdded = "dateAdded"
        static let condition = "condition"
        static let notes = "notes"
        static let status = "status"
        static let sku = "sku"
    }

    struct SaleTable {
        static let databaseTableName = "sale"
        static let id = "id"
        static let itemId = "itemId"
        static let soldPrice = "soldPrice"
        static let platform = "platform"
        static let fees = "fees"
        static let dateSold = "dateSold"
        static let buyer = "buyer"
    }

    struct PurchaseTable {
        static let databaseTableName = "purchase"
        static let id = "id"
        static let supplier = "supplier"
        static let batchName = "batchName"
        static let datePurchased = "datePurchased"
        static let cost = "cost"
    }

    struct BrandTable {
        static let databaseTableName = "brand"
        static let id = "id"
        static let name = "name"
    }

    struct CategoryTable {
        static let databaseTableName = "category"
        static let id = "id"
        static let name = "name"
    }

    struct ImageAttachmentTable {
        static let databaseTableName = "imageAttachment"
        static let id = "id"
        static let itemId = "itemId"
        static let fileName = "fileName"
        static let relativePath = "relativePath"
        static let createdAt = "createdAt"
    }
}
