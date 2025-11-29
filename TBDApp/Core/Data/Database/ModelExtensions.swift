import Foundation
import GRDB

// MARK: - Item
extension Item: FetchableRecord, PersistableRecord {
    static var databaseTableName: String { SchemaDefinitions.ItemTable.databaseTableName }
}

// MARK: - Sale
extension Sale: FetchableRecord, PersistableRecord {
    static var databaseTableName: String { SchemaDefinitions.SaleTable.databaseTableName }
}

// MARK: - Purchase
extension Purchase: FetchableRecord, PersistableRecord {
    static var databaseTableName: String { SchemaDefinitions.PurchaseTable.databaseTableName }
}

// MARK: - Brand
extension Brand: FetchableRecord, PersistableRecord {
    static var databaseTableName: String { SchemaDefinitions.BrandTable.databaseTableName }
}

// MARK: - Category
extension Category: FetchableRecord, PersistableRecord {
    static var databaseTableName: String { SchemaDefinitions.CategoryTable.databaseTableName }
}

// MARK: - ImageAttachment
extension ImageAttachment: FetchableRecord, PersistableRecord {
    static var databaseTableName: String {
        SchemaDefinitions.ImageAttachmentTable.databaseTableName
    }
}
