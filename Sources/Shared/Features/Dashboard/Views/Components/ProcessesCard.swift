import SwiftUI

struct ProcessesCard: View {
    let alerts: [StockAlert]
    let onViewAll: () -> Void
    let onViewAlert: (StockAlert) -> Void

    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                // Header
                HStack {
                    Text("Stock Alerts")
                        .font(theme.typography.cardTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Button(action: onViewAll) {
                        Text("View All")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }

                // Content
                if alerts.isEmpty {
                    // Empty State
                    VStack(spacing: theme.spacing.s) {
                        Spacer()

                        Image(systemName: "checkmark.shield")
                            .font(.system(size: 32))
                            .foregroundColor(theme.colors.accentPositive)

                        Text("All stock levels healthy")
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.textPrimary)

                        Text("No low stock warnings at this time.")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    // Alert List
                    VStack(spacing: theme.spacing.s) {
                        ForEach(alerts) { alert in
                            HStack(spacing: theme.spacing.m) {
                                // Icon
                                Image(systemName: alert.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(alert.severityColor(theme: theme))
                                    .frame(width: 32, height: 32)
                                    .background(theme.colors.surfaceElevated)
                                    .clipShape(Circle())

                                // Info
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(alert.title)
                                        .font(theme.typography.body)
                                        .foregroundColor(theme.colors.textPrimary)

                                    Text(alert.message)
                                        .font(theme.typography.caption)
                                        .foregroundColor(theme.colors.textSecondary)
                                }

                                Spacer()

                                // Action Button
                                Button(action: { onViewAlert(alert) }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(theme.colors.textSecondary)
                                        .frame(width: 28, height: 28)
                                        .background(theme.colors.surfaceElevated)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(theme.spacing.m)
                            .background(theme.colors.surfaceSecondary)
                            .cornerRadius(theme.radii.small)
                        }
                    }
                }
            }
        }
        .frame(minHeight: 260)
    }
}
