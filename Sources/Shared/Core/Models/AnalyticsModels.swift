import Foundation

/// Protocol for data points used in AppChart
/// Note: This is also defined in AppChart.swift, we might need to unify or just use this one if we remove the other.
/// For now, let's assume AppChart.swift definition is the primary one if it's in the same module.
/// However, to avoid circular dependencies or scope issues, let's rely on the one in AppChart.swift if possible.
/// But since I can't easily see if AppChart.swift is compiled before this, I'll define the conformance in an extension if the protocol is available.
/// Actually, I'll define the models here and conform them to ChartDataPoint in AppChart.swift or here if ChartDataPoint is visible.

public struct SalesDataPoint: Identifiable, Equatable {
    public let id: UUID
    public let date: Date
    public let amount: Double

    public init(id: UUID = UUID(), date: Date, amount: Double) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}

public struct CategoryDataPoint: Identifiable, Codable {
    public let id: UUID
    public let category: String
    public let amount: Double
    public let count: Int

    public init(id: UUID = UUID(), category: String, amount: Double, count: Int) {
        self.id = id
        self.category = category
        self.amount = amount
        self.count = count
    }
}

public struct RecentItemInfo: Identifiable, Equatable, Codable {
    public let id: UUID
    public let title: String
    public let dateAdded: Date
    public let price: Double
    public let status: String
    public let condition: String

    public init(
        id: UUID = UUID(), title: String, dateAdded: Date, price: Double, status: String,
        condition: String
    ) {
        self.id = id
        self.title = title
        self.dateAdded = dateAdded
        self.price = price
        self.status = status
        self.condition = condition
    }
}

public struct ItemCountDataPoint: Identifiable, Equatable {
    public let id: UUID
    public let date: Date
    public let count: Int

    public init(id: UUID = UUID(), date: Date, count: Int) {
        self.id = id
        self.date = date
        self.count = count
    }
}

public struct ActivityItem: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let description: String
    public let type: ActivityType
    public let date: Date

    public enum ActivityType: String, Codable {
        case sale
        case purchase
        case alert
    }

    public init(
        id: UUID = UUID(), title: String, description: String, type: ActivityType, date: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.date = date
    }
}
