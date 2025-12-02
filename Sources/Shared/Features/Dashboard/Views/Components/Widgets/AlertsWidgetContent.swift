import SwiftUI

/// Content view for priority alerts widget
///
/// Displays a list of active alerts with dismiss functionality.
/// Reuses the AlertChip component for individual alert rendering.
struct AlertsWidgetContent: View {

    let alerts: [DashboardAlert]
    let onDismiss: (DashboardAlert) -> Void

    var activeAlerts: [DashboardAlert] {
        alerts.filter { !$0.isDismissed }
    }

    init(
        alerts: [DashboardAlert],
        onDismiss: @escaping (DashboardAlert) -> Void = { _ in }
    ) {
        self.alerts = alerts
        self.onDismiss = onDismiss
    }

    var body: some View {
        if activeAlerts.isEmpty {
            AlertsEmptyState()
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(activeAlerts) { alert in
                        AlertChip(
                            alert: alert,
                            onDismiss: {
                                onDismiss(alert)
                            }
                        )
                    }
                }
                .padding(12)
            }
        }
    }
}

/// Empty state for alerts widget
struct AlertsEmptyState: View {

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 32))
                .foregroundColor(.green)

            Text("All clear!")
                .font(.title3)
                .foregroundColor(.primary)

            Text("No active alerts at this time")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
