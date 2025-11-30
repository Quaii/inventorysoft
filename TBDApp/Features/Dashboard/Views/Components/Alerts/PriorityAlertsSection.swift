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
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                // Section Title
                Text("Priority Alerts")
                    .font(theme.typography.sectionTitle)
                    .foregroundColor(theme.colors.textPrimary)

                // Alert Chips
                VStack(spacing: theme.spacing.s) {
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
