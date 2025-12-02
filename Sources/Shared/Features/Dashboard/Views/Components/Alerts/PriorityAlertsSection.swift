import SwiftUI

/// Priority Alerts section for the dashboard
struct PriorityAlertsSection: View {
    let alerts: [DashboardAlert]
    let onDismiss: (DashboardAlert) -> Void

    @Environment(\.theme) var theme

    var activeAlerts: [DashboardAlert] {
        alerts.filter { !$0.isDismissed }
    }

    var body: some View {
        if !activeAlerts.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                // Section Title
                Text("Priority Alerts")
                    .font(.title2)
                    .foregroundColor(.primary)

                // Alert Chips
                VStack(spacing: 8) {
                    ForEach(activeAlerts) { alert in
                        AlertChip(
                            alert: alert,
                            onDismiss: {
                                onDismiss(alert)
                            })
                    }
                }
            }
        }
    }
}
