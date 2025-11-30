import SwiftUI

struct SystemOverviewCard: View {
    let itemsPerDay: Int?
    let totalCaptured: Int?
    let onSettingsAction: () -> Void

    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                // Icon + Title
                HStack(spacing: theme.spacing.m) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 18))
                        .foregroundColor(theme.colors.accentPrimary)
                        .frame(width: 40, height: 40)
                        .background(theme.colors.surfaceElevated)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text("System Overview")
                            .font(theme.typography.cardTitle)
                            .foregroundColor(theme.colors.textPrimary)

                        if totalCaptured == nil && itemsPerDay == nil {
                            Text("No data captured yet")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                        } else {
                            Text("Real-time metrics from your inventory")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                        }
                    }
                }

                Spacer()

                // Metrics Row
                HStack(spacing: theme.spacing.xl) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ITEMS / DAY")
                            .font(theme.typography.tableHeader)
                            .foregroundColor(theme.colors.textSecondary)

                        Text(itemsPerDay.map { "\($0)" } ?? "—")
                            .font(theme.typography.numericMedium)
                            .foregroundColor(theme.colors.textPrimary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("TOTAL CAPTURED")
                            .font(theme.typography.tableHeader)
                            .foregroundColor(theme.colors.textSecondary)

                        Text(totalCaptured.map { "\($0)" } ?? "—")
                            .font(theme.typography.numericMedium)
                            .foregroundColor(theme.colors.textPrimary)
                    }
                }

                Spacer()

                // Settings Button
                AppButton(
                    title: "System Settings",
                    icon: "slider.horizontal.3",
                    style: .primary,
                    action: onSettingsAction
                )
            }
        }
        .frame(minHeight: 260)
    }
}
