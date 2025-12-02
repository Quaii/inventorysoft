import Foundation
import SwiftUI

/// Stock alert model for dashboard notifications
public struct StockAlert: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let message: String
    public let severity: AlertType

    public var icon: String {
        switch severity {
        case .low: return "exclamationmark.triangle"
        case .medium: return "exclamationmark.circle"
        case .high: return "exclamationmark.octagon"
        }
    }

    public func severityColor() -> Color {
        switch severity {
        case .low: return .yellow
        case .medium: return .orange
        case .high: return .red
        }
    }
}

public enum AlertType: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}
