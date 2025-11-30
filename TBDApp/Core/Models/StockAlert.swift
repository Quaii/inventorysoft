import Foundation
import SwiftUI

/// Stock alert model for dashboard notifications
struct StockAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let severity: AlertSeverity

    var icon: String {
        switch severity {
        case .low: return "exclamationmark.triangle"
        case .medium: return "exclamationmark.circle"
        case .high: return "exclamationmark.octagon"
        }
    }

    func severityColor(theme: Theme) -> Color {
        switch severity {
        case .low: return theme.colors.accentWarning
        case .medium: return theme.colors.warning
        case .high: return theme.colors.error
        }
    }
}

enum AlertSeverity {
    case low
    case medium
    case high
}
