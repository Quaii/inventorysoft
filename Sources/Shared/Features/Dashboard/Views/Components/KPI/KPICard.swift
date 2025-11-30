import SwiftUI

/// Individual KPI card component
struct KPICard: View {
    let kpi: DashboardKPI
    let onTap: () -> Void

    @Environment(\.theme) var theme
    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            AppCard {
                VStack(alignment: .leading, spacing: theme.spacing.m) {
                    // Icon and Title Row
                    HStack(spacing: theme.spacing.s) {
                        Image(systemName: kpi.metricKey.icon)
                            .font(.system(size: 16))
                            .foregroundColor(theme.colors.accentSecondary)
                            .frame(width: 24, height: 24)

                        Text(kpi.title)
                            .font(theme.typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(theme.colors.textSecondary)

                        Spacer()
                    }

                    // Value
                    Text(kpi.value)
                        .font(theme.typography.pageTitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)

                    // Secondary Text (optional)
                    if let secondaryText = kpi.secondaryText {
                        Text(secondaryText)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
                .padding(theme.spacing.m)
            }
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
