import Foundation

/// Protocol for data points used in AppChart
/// Note: This is also defined in AppChart.swift, we might need to unify or just use this one if we remove the other.
/// For now, let's assume AppChart.swift definition is the primary one if it's in the same module.
/// However, to avoid circular dependencies or scope issues, let's rely on the one in AppChart.swift if possible.
/// But since I can't easily see if AppChart.swift is compiled before this, I'll define the conformance in an extension if the protocol is available.
/// Actually, I'll define the models here and conform them to ChartDataPoint in AppChart.swift or here if ChartDataPoint is visible.

struct SalesDataPoint: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double

    init(id: UUID = UUID(), date: Date, amount: Double) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}

struct CategoryDataPoint: Identifiable, Codable {
    let id: UUID
    let category: String
    let amount: Double
    let count: Int

    init(id: UUID = UUID(), category: String, amount: Double, count: Int) {
        self.id = id
        self.category = category
        self.amount = amount
        self.count = count
    }
}

struct TopProductInfo: Identifiable, Codable {
    let id: UUID
    let name: String
    let quantity: Int
    let revenue: Double

    init(id: UUID = UUID(), name: String, quantity: Int, revenue: Double) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.revenue = revenue
    }
}

struct ItemCountDataPoint: Identifiable, Codable {
    let id: UUID
    let date: Date
    let count: Int

    init(id: UUID = UUID(), date: Date, count: Int) {
        self.id = id
        self.date = date
        self.count = count
    }
}

struct ActivityItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: ActivityType
    let date: Date

    enum ActivityType: String, Codable {
        case sale
        case purchase
        case alert
    }

    init(id: UUID = UUID(), title: String, description: String, type: ActivityType, date: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.date = date
    }
}
