import Foundation

// MARK: - Data Sources

public enum ChartDataSource: String, Codable, CaseIterable {
    case inventory
    case sales
    case purchases
    case combined

    var displayName: String {
        switch self {
        case .inventory: return "Inventory"
        case .sales: return "Sales"
        case .purchases: return "Purchases"
        case .combined: return "Combined"
        }
    }
}

public enum ChartAggregation: String, Codable, CaseIterable {
    case sum
    case average
    case count
    case min
    case max

    var displayName: String {
        switch self {
        case .sum: return "Sum"
        case .average: return "Average"
        case .count: return "Count"
        case .min: return "Minimum"
        case .max: return "Maximum"
        }
    }
}

// MARK: - Formula Support

public enum FormulaOperation: String, Codable, CaseIterable {
    case divide
    case subtract
    case add
    case multiply

    public var displayName: String {
        switch self {
        case .divide: return "Divide"
        case .subtract: return "Subtract"
        case .add: return "Add"
        case .multiply: return "Multiply"
        }
    }

    public var symbol: String {
        switch self {
        case .divide: return "/"
        case .subtract: return "-"
        case .add: return "+"
        case .multiply: return "×"
        }
    }
}

public struct FormulaConfig: Codable, Equatable {
    public var operation: FormulaOperation
    public var field1: String
    public var field2: String

    public init(operation: FormulaOperation, field1: String, field2: String) {
        self.operation = operation
        self.field1 = field1
        self.field2 = field2
    }
}

// MARK: - Chart Type

public enum ChartType: String, Codable, CaseIterable {
    case none
    case bar
    case line
    case area
    case donut
    case table

    public var displayName: String {
        switch self {
        case .none: return "None"
        case .bar: return "Bar Chart"
        case .line: return "Line Chart"
        case .area: return "Area Chart"
        case .donut: return "Donut Chart"
        case .table: return "Table"
        }
    }

    public var icon: String {
        switch self {
        case .none: return "minus.circle"
        case .bar: return "chart.bar"
        case .line: return "chart.xyaxis.line"
        case .area: return "chart.line.uptrend.xyaxis"
        case .donut: return "chart.pie"
        case .table: return "tablecells"
        }
    }
}

// MARK: - Chart Time Range

public enum ChartTimeRange: String, Codable, CaseIterable {
    case day
    case week
    case month
    case quarter
    case year

    public var displayName: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .quarter: return "Quarter"
        case .year: return "Year"
        }
    }
}

// MARK: - Chart Definition

public struct ChartDefinition: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var chartType: ChartType
    public var dataSource: ChartDataSource
    public var xField: String
    public var yField: String
    public var aggregation: ChartAggregation
    public var groupBy: String?
    public var colorPalette: String
    public var formula: FormulaConfig?
    public var sortOrder: Int

    public init(
        id: UUID = UUID(),
        title: String,
        chartType: ChartType,
        dataSource: ChartDataSource,
        xField: String,
        yField: String,
        aggregation: ChartAggregation,
        groupBy: String? = nil,
        colorPalette: String = "default",
        formula: FormulaConfig? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.chartType = chartType
        self.dataSource = dataSource
        self.xField = xField
        self.yField = yField
        self.aggregation = aggregation
        self.groupBy = groupBy
        self.colorPalette = colorPalette
        self.formula = formula
        self.sortOrder = sortOrder
    }

    // Default chart definitions
    static let revenueTrend = ChartDefinition(
        title: "Revenue Trend",
        chartType: .bar,
        dataSource: .sales,
        xField: "dateSold",
        yField: "soldPrice",
        aggregation: .sum,
        groupBy: nil,
        sortOrder: 0
    )

    static let salesByCategory = ChartDefinition(
        title: "Sales by Category",
        chartType: .donut,
        dataSource: .inventory,
        xField: "category",
        yField: "id",
        aggregation: .count,
        groupBy: "category",
        sortOrder: 1
    )

    static let topProducts = ChartDefinition(
        title: "Top Products",
        chartType: .bar,
        dataSource: .sales,
        xField: "itemId",
        yField: "soldPrice",
        aggregation: .sum,
        groupBy: nil,
        sortOrder: 2
    )
    func duplicated() -> ChartDefinition {
        ChartDefinition(
            id: UUID(),
            title: "\(title) (Copy)",
            chartType: chartType,
            dataSource: dataSource,
            xField: xField,
            yField: yField,
            aggregation: aggregation,
            groupBy: groupBy,
            colorPalette: colorPalette,
            formula: formula,
            sortOrder: sortOrder
        )
    }
}

// MARK: - Color Palettes

public struct ChartColorPalette {
    public static let palettes: [String: [String]] = [
        "default": ["#FFFFFF", "#3DDC97", "#F2A93B", "#3498DB", "#E74C3C"],
        "blue": ["#3498DB", "#5DADE2", "#85C1E9", "#AED6F1", "#D6EAF8"],
        "green": ["#27AE60", "#52BE80", "#7DCEA0", "#A9DFBF", "#D5F4E6"],
        "purple": ["#8E44AD", "#A569BD", "#BB8FCE", "#D2B4DE", "#E8DAEF"],
        "orange": ["#E67E22", "#EB984E", "#F0B27A", "#F5CBA7", "#FAE5D3"],
    ]

    public static func colors(for palette: String) -> [String] {
        palettes[palette] ?? palettes["default"]!
    }
}
