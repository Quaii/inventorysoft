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

        // Migration v2: Customization Features
        migrator.registerMigration("v2") { db in
            // Add isPrimary to ImageAttachment
            try db.alter(table: SchemaDefinitions.ImageAttachmentTable.databaseTableName) { t in
                t.add(column: SchemaDefinitions.ImageAttachmentTable.isPrimary, .boolean).notNull()
                    .defaults(to: false)
            }

            // CustomFieldDefinition Table
            try db.create(table: SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName) {
                t in
                t.column(SchemaDefinitions.CustomFieldDefinitionTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.CustomFieldDefinitionTable.name, .text).notNull()
                t.column(SchemaDefinitions.CustomFieldDefinitionTable.type, .text).notNull()
                t.column(SchemaDefinitions.CustomFieldDefinitionTable.appliesTo, .text).notNull()
                t.column(SchemaDefinitions.CustomFieldDefinitionTable.selectOptions, .text)
                t.column(SchemaDefinitions.CustomFieldDefinitionTable.isRequired, .boolean)
                    .notNull().defaults(to: false)
                t.column(SchemaDefinitions.CustomFieldDefinitionTable.sortOrder, .integer).notNull()
                t.column(SchemaDefinitions.CustomFieldDefinitionTable.createdAt, .date).notNull()
            }

            // CustomFieldValue Table
            try db.create(table: SchemaDefinitions.CustomFieldValueTable.databaseTableName) { t in
                t.column(SchemaDefinitions.CustomFieldValueTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.CustomFieldValueTable.customFieldId, .text).notNull()
                    .references(
                        SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName,
                        onDelete: .cascade)
                t.column(SchemaDefinitions.CustomFieldValueTable.entityId, .text).notNull()
                t.column(SchemaDefinitions.CustomFieldValueTable.value, .text).notNull()
            }

            // TableColumnConfig Table
            try db.create(table: SchemaDefinitions.TableColumnConfigTable.databaseTableName) { t in
                t.column(SchemaDefinitions.TableColumnConfigTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.TableColumnConfigTable.tableType, .text).notNull()
                t.column(SchemaDefinitions.TableColumnConfigTable.field, .text).notNull()
                t.column(SchemaDefinitions.TableColumnConfigTable.label, .text).notNull()
                t.column(SchemaDefinitions.TableColumnConfigTable.width, .double)
                t.column(SchemaDefinitions.TableColumnConfigTable.sortOrder, .integer).notNull()
                    .defaults(to: 0)
                t.column(SchemaDefinitions.TableColumnConfigTable.isVisible, .boolean).notNull()
                    .defaults(to: true)
                t.column(SchemaDefinitions.TableColumnConfigTable.isCustomField, .boolean).notNull()
                    .defaults(to: false)
            }

            // DashboardWidget Table
            try db.create(table: SchemaDefinitions.DashboardWidgetTable.databaseTableName) { t in
                t.column(SchemaDefinitions.DashboardWidgetTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.DashboardWidgetTable.type, .text).notNull()
                t.column(SchemaDefinitions.DashboardWidgetTable.metric, .text).notNull()
                t.column(SchemaDefinitions.DashboardWidgetTable.size, .text).notNull()
                t.column(SchemaDefinitions.DashboardWidgetTable.positionRow, .integer).notNull()
                    .defaults(to: 0)
                t.column(SchemaDefinitions.DashboardWidgetTable.positionCol, .integer).notNull()
                    .defaults(to: 0)
                t.column(SchemaDefinitions.DashboardWidgetTable.chartType, .text).notNull()
                    .defaults(to: "none")
                t.column(SchemaDefinitions.DashboardWidgetTable.isVisible, .boolean).notNull()
                    .defaults(to: true)
                t.column(SchemaDefinitions.DashboardWidgetTable.sortOrder, .integer).notNull()
                    .defaults(to: 0)
            }

            // ImportProfile Table
            try db.create(table: SchemaDefinitions.ImportProfileTable.databaseTableName) { t in
                t.column(SchemaDefinitions.ImportProfileTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.ImportProfileTable.name, .text).notNull()
                t.column(SchemaDefinitions.ImportProfileTable.targetType, .text).notNull()
                t.column(SchemaDefinitions.ImportProfileTable.mappings, .text).notNull()  // JSON encoded
                t.column(SchemaDefinitions.ImportProfileTable.createdAt, .date).notNull()
                t.column(SchemaDefinitions.ImportProfileTable.updatedAt, .date).notNull()
            }

            // UserPreferences Table
            try db.create(table: SchemaDefinitions.UserPreferencesTable.databaseTableName) { t in
                t.column(SchemaDefinitions.UserPreferencesTable.id, .text).primaryKey()
                t.column(SchemaDefinitions.UserPreferencesTable.baseCurrency, .text).notNull()
                t.column(SchemaDefinitions.UserPreferencesTable.displayCurrency, .text).notNull()
                t.column(SchemaDefinitions.UserPreferencesTable.dateFormat, .text).notNull()
                t.column(SchemaDefinitions.UserPreferencesTable.firstDayOfWeek, .text).notNull()
                t.column(SchemaDefinitions.UserPreferencesTable.themeMode, .text).notNull()
                t.column(SchemaDefinitions.UserPreferencesTable.compactMode, .boolean).notNull()
                    .defaults(to: false)
                t.column(SchemaDefinitions.UserPreferencesTable.accentColor, .text).notNull()
            }
        }

        // Migration v3: Rename 'order' to 'sortOrder' (fixes SQL reserved keyword bug)
        migrator.registerMigration("v3_rename_order_column") { db in
            // NOTE: SQLite doesn't support simple column renaming, so we must:
            // 1. Create new columns with 'sortOrder' name
            // 2. Copy data from 'order' to 'sortOrder'
            //  3. The old 'order' column will remain but won't be used
            // Future fresh installs (from v2) will use 'sortOrder' from the start

            // Check if 'order' column exists (for databases created before v3)
            let tableExists = try db.tableExists(
                SchemaDefinitions.DashboardWidgetTable.databaseTableName)
            let columns =
                tableExists
                ? try db.columns(in: SchemaDefinitions.DashboardWidgetTable.databaseTableName) : []
            let hasOrderColumn = tableExists && columns.contains { $0.name == "order" }

            if hasOrderColumn {
                // Add new sortOrder columns
                try db.alter(table: SchemaDefinitions.DashboardWidgetTable.databaseTableName) { t in
                    t.add(column: SchemaDefinitions.DashboardWidgetTable.sortOrder, .integer)
                        .notNull().defaults(to: 0)
                }

                try db.alter(table: SchemaDefinitions.TableColumnConfigTable.databaseTableName) {
                    t in
                    t.add(column: SchemaDefinitions.TableColumnConfigTable.sortOrder, .integer)
                        .notNull().defaults(to: 0)
                }

                try db.alter(table: SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName)
                { t in
                    t.add(column: SchemaDefinitions.CustomFieldDefinitionTable.sortOrder, .integer)
                        .notNull().defaults(to: 0)
                }

                // Copy data from 'order' to 'sortOrder'
                try db.execute(
                    sql:
                        "UPDATE \(SchemaDefinitions.DashboardWidgetTable.databaseTableName) SET \(SchemaDefinitions.DashboardWidgetTable.sortOrder) = \"order\""
                )
                try db.execute(
                    sql:
                        "UPDATE \(SchemaDefinitions.TableColumnConfigTable.databaseTableName) SET \(SchemaDefinitions.TableColumnConfigTable.sortOrder) = \"order\""
                )
                try db.execute(
                    sql:
                        "UPDATE \(SchemaDefinitions.CustomFieldDefinitionTable.databaseTableName) SET \(SchemaDefinitions.CustomFieldDefinitionTable.sortOrder) = \"order\""
                )
            }
        }

        // Migration v4: Clean rebuild of configuration tables with proper defaults
        migrator.registerMigration("v4_rebuild_config_tables") { db in
            // This migration provides a clean slate for configuration tables
            // only if they're causing issues. It drops and recreates them with
            // the correct schema including all DEFAULT values.

            let dashboardTableExists = try db.tableExists(
                SchemaDefinitions.DashboardWidgetTable.databaseTableName)
            let columnTableExists = try db.tableExists(
                SchemaDefinitions.TableColumnConfigTable.databaseTableName)

            if dashboardTableExists {
                // Drop and recreate dashboardWidget with proper defaults
                try db.drop(table: SchemaDefinitions.DashboardWidgetTable.databaseTableName)
                try db.create(table: SchemaDefinitions.DashboardWidgetTable.databaseTableName) {
                    t in
                    t.column(SchemaDefinitions.DashboardWidgetTable.id, .text).primaryKey()
                    t.column(SchemaDefinitions.DashboardWidgetTable.type, .text).notNull()
                    t.column(SchemaDefinitions.DashboardWidgetTable.metric, .text).notNull()
                    t.column(SchemaDefinitions.DashboardWidgetTable.size, .text).notNull()
                    t.column(SchemaDefinitions.DashboardWidgetTable.positionRow, .integer).notNull()
                        .defaults(to: 0)
                    t.column(SchemaDefinitions.DashboardWidgetTable.positionCol, .integer).notNull()
                        .defaults(to: 0)
                    t.column(SchemaDefinitions.DashboardWidgetTable.chartType, .text).notNull()
                        .defaults(to: "none")
                    t.column(SchemaDefinitions.DashboardWidgetTable.isVisible, .boolean).notNull()
                        .defaults(to: true)
                    t.column(SchemaDefinitions.DashboardWidgetTable.sortOrder, .integer).notNull()
                        .defaults(to: 0)
                }
            }

            if columnTableExists {
                // Drop and recreate tableColumnConfig with proper defaults
                try db.drop(table: SchemaDefinitions.TableColumnConfigTable.databaseTableName)
                try db.create(
                    table: SchemaDefinitions.TableColumnConfigTable.databaseTableName
                ) { t in
                    t.column(SchemaDefinitions.TableColumnConfigTable.id, .text).primaryKey()
                    t.column(SchemaDefinitions.TableColumnConfigTable.tableType, .text).notNull()
                    t.column(SchemaDefinitions.TableColumnConfigTable.field, .text).notNull()
                    t.column(SchemaDefinitions.TableColumnConfigTable.label, .text).notNull()
                    t.column(SchemaDefinitions.TableColumnConfigTable.width, .double)
                    t.column(SchemaDefinitions.TableColumnConfigTable.sortOrder, .integer).notNull()
                        .defaults(to: 0)
                    t.column(SchemaDefinitions.TableColumnConfigTable.isVisible, .boolean).notNull()
                        .defaults(to: true)
                    t.column(SchemaDefinitions.TableColumnConfigTable.isCustomField, .boolean)
                        .notNull()
                        .defaults(to: false)
                }
            }
        }
    }
}
