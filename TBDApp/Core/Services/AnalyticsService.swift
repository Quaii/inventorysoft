import Foundation

protocol AnalyticsServiceProtocol {
    func trackEvent(_ name: String, properties: [String: Any]?)
}

class AnalyticsService: AnalyticsServiceProtocol {
    func trackEvent(_ name: String, properties: [String: Any]? = nil) {
        print("Analytics Event: \(name), properties: \(String(describing: properties))")
    }
}
