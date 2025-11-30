import SwiftUI

/// Individual alert chip component
struct AlertChip: View {
    let alert: DashboardAlert
    let onDismiss: () -> Void

    @Environment(\.theme) var theme

    private var severityColor: Color {
        switch alert.severity {
        case .info: return theme.colors.accentSecondary
        case .warning: return .orange
        case .success: return .green
        }
    }

    var body: some View {
        HStack(spacing: theme.spacing.s) {
            // Icon
            Image(systemName: alert.severity.icon)
                .font(.system(size: 14))
                .foregroundColor(severityColor)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Text(alert.message)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()

            // Dismiss button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
        }
        .padding(theme.spacing.m)
        .background(severityColor.opacity(0.1))
        .cornerRadius(theme.radii.small)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.small)
                .stroke(severityColor.opacity(0.3), lineWidth: 1)
        )
    }
}
