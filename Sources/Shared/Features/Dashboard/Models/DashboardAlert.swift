import Foundation

/// Represents an alert shown on the dashboard
struct DashboardAlert: Identifiable, Codable {
    let id: UUID
    var type: DashboardAlertType
    var title: String
    var message: String
    var severity: DashboardAlertSeverity
    var isDismissed: Bool

    init(
        id: UUID = UUID(),
        type: DashboardAlertType,
        title: String,
        message: String,
        severity: DashboardAlertSeverity,
        isDismissed: Bool = false
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.severity = severity
        self.isDismissed = isDismissed
    }
}

enum DashboardAlertType: String, Codable {
    case agingItems
    case profitTrend
    case bestBrand
    case lowStock
    case other
}

enum DashboardAlertSeverity: String, Codable {
    case info
    case warning
    case success

    var color: String {
        switch self {
        case .info: return "blue"
        case .warning: return "yellow"
        case .success: return "green"
        }
    }

    var icon: String {
        switch self {
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .success: return "checkmark.circle"
        }
    }
}
