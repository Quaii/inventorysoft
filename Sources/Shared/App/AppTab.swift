import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case inventory
    case sales
    case purchases
    case analytics
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .inventory: return "Inventory"
        case .sales: return "Sales"
        case .purchases: return "Purchases"
        case .analytics: return "Analytics"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .inventory: return "box.truck"
        case .sales: return "tag"
        case .purchases: return "cart"
        case .analytics: return "chart.bar.xaxis"
        case .settings: return "gearshape"
        }
    }
}
