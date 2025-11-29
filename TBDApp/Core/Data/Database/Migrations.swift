import Foundation
import GRDB

struct Migrations {
    static func register(in migrator: inout DatabaseMigrator) throws {
        migrator.registerMigration("v1") { db in
            // Brand Table
            try db.create(table: SchemaDefinitions.BrandTable.databaseTableName) { t in
                t.column(SchemaDefinitions.BrandTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.BrandTable.name, .text).notNull()
            }

            // Category Table
            try db.create(table: SchemaDefinitions.CategoryTable.databaseTableName) { t in
                t.column(SchemaDefinitions.CategoryTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.CategoryTable.name, .text).notNull()
            }

            // Item Table
            try db.create(table: SchemaDefinitions.ItemTable.databaseTableName) { t in
                t.column(SchemaDefinitions.ItemTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.ItemTable.title, .text).notNull()
                t.column(SchemaDefinitions.ItemTable.brandId, .text).references(
                    SchemaDefinitions.BrandTable.databaseTableName, onDelete: .setNull)
                t.column(SchemaDefinitions.ItemTable.categoryId, .text).references(
                    SchemaDefinitions.CategoryTable.databaseTableName, onDelete: .setNull)
                t.column(SchemaDefinitions.ItemTable.purchasePrice, .double).notNull()
                t.column(SchemaDefinitions.ItemTable.quantity, .integer).notNull().defaults(to: 1)
                t.column(SchemaDefinitions.ItemTable.dateAdded, .date).notNull()
                t.column(SchemaDefinitions.ItemTable.condition, .text).notNull()
                t.column(SchemaDefinitions.ItemTable.notes, .text)
                t.column(SchemaDefinitions.ItemTable.status, .text).notNull()
                t.column(SchemaDefinitions.ItemTable.sku, .text)
            }

            // Sale Table
            try db.create(table: SchemaDefinitions.SaleTable.databaseTableName) { t in
                t.column(SchemaDefinitions.SaleTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.SaleTable.itemId, .text).notNull().references(
                    SchemaDefinitions.ItemTable.databaseTableName, onDelete: .cascade)
                t.column(SchemaDefinitions.SaleTable.soldPrice, .double).notNull()
                t.column(SchemaDefinitions.SaleTable.platform, .text).notNull()
                t.column(SchemaDefinitions.SaleTable.fees, .double).notNull()
                t.column(SchemaDefinitions.SaleTable.dateSold, .date).notNull()
                t.column(SchemaDefinitions.SaleTable.buyer, .text)
            }

            // Purchase Table
            try db.create(table: SchemaDefinitions.PurchaseTable.databaseTableName) { t in
                t.column(SchemaDefinitions.PurchaseTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.PurchaseTable.supplier, .text).notNull()
                t.column(SchemaDefinitions.PurchaseTable.batchName, .text)
                t.column(SchemaDefinitions.PurchaseTable.datePurchased, .date).notNull()
                t.column(SchemaDefinitions.PurchaseTable.cost, .double).notNull()
            }

            // ImageAttachment Table
            try db.create(table: SchemaDefinitions.ImageAttachmentTable.databaseTableName) { t in
                t.column(SchemaDefinitions.ImageAttachmentTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.ImageAttachmentTable.itemId, .text).notNull().references(
                    SchemaDefinitions.ItemTable.databaseTableName, onDelete: .cascade)
                t.column(SchemaDefinitions.ImageAttachmentTable.fileName, .text).notNull()
                t.column(SchemaDefinitions.ImageAttachmentTable.relativePath, .text).notNull()
                t.column(SchemaDefinitions.ImageAttachmentTable.createdAt, .date).notNull()
            }
        }
    }
}
