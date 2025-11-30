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
        static let isPrimary = "isPrimary"
    }

    struct CustomFieldDefinitionTable {
        static let databaseTableName = "customFieldDefinition"
        static let id = "id"
        static let name = "name"
        static let type = "type"
        static let appliesTo = "appliesTo"
        static let selectOptions = "selectOptions"
        static let isRequired = "isRequired"
        static let sortOrder = "sortOrder"
        static let createdAt = "createdAt"
    }

    struct CustomFieldValueTable {
        static let databaseTableName = "customFieldValue"
        static let id = "id"
        static let customFieldId = "customFieldId"
        static let entityId = "entityId"
        static let value = "value"
    }

    struct TableColumnConfigTable {
        static let databaseTableName = "tableColumnConfig"
        static let id = "id"
        static let tableType = "tableType"
        static let field = "field"
        static let label = "label"
        static let width = "width"
        static let sortOrder = "sortOrder"
        static let isVisible = "isVisible"
        static let isCustomField = "isCustomField"
    }

    struct DashboardWidgetTable {
        static let databaseTableName = "dashboardWidget"
        static let id = "id"
        static let type = "type"
        static let metric = "metric"
        static let size = "size"
        static let positionRow = "positionRow"
        static let positionCol = "positionCol"
        static let chartType = "chartType"
        static let isVisible = "isVisible"
        static let sortOrder = "sortOrder"
    }

    struct ImportProfileTable {
        static let databaseTableName = "importProfile"
        static let id = "id"
        static let name = "name"
        static let targetType = "targetType"
        static let mappings = "mappings"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }

    struct UserPreferencesTable {
        static let databaseTableName = "userPreferences"
        static let id = "id"
        // General
        static let baseCurrency = "baseCurrency"
        static let displayCurrency = "displayCurrency"
        static let dateFormat = "dateFormat"
        static let numberFormattingLocale = "numberFormattingLocale"
        static let firstDayOfWeek = "firstDayOfWeek"
        // Appearance
        static let themeMode = "themeMode"
        static let compactMode = "compactMode"
        static let accentColor = "accentColor"
        static let sidebarCollapseBehavior = "sidebarCollapseBehavior"
        // Dashboard & Analytics
        static let dashboardInitialLayout = "dashboardInitialLayout"
        static let allowDashboardEditing = "allowDashboardEditing"
        static let defaultAnalyticsRange = "defaultAnalyticsRange"
        static let defaultAnalyticsInterval = "defaultAnalyticsInterval"
        // Data Management
        static let backupLocationPath = "backupLocationPath"
        static let backupFrequency = "backupFrequency"
    }

    struct ChartDefinitionTable {
        static let databaseTableName = "chartDefinition"
        static let id = "id"
        static let title = "title"
        static let chartType = "chartType"
        static let dataSource = "dataSource"
        static let xField = "xField"
        static let yField = "yField"
        static let aggregation = "aggregation"
        static let groupBy = "groupBy"
        static let colorPalette = "colorPalette"
        static let formula = "formula"  // JSON encoded
        static let sortOrder = "sortOrder"
    }

    struct UserDashboardWidgetTable {
        static let databaseTableName = "user_dashboard_widget"
        static let id = "id"
        static let name = "name"
        static let type = "type"
        static let size = "size"
        static let position = "position"
        static let configuration = "configuration"  // JSON encoded widget config
        static let isVisible = "isVisible"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }

    struct AnalyticsWidgetTable {
        static let databaseTableName = "user_analytics_widget"
        static let id = "id"
        static let name = "name"
        static let type = "type"
        static let size = "size"
        static let position = "position"
        static let configuration = "configuration"
        static let isVisible = "isVisible"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
}
