import SwiftUI

/// Individual alert chip component
struct AlertChip: View {
    let alert: DashboardAlert
    let onDismiss: () -> Void

    private var severityColor: Color {
        switch alert.severity {
        case .info: return .blue
        case .warning: return .orange
        case .success: return .green
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            // Icon
            Image(systemName: alert.severity.icon)
                .font(.system(size: 14))
                .foregroundColor(severityColor)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Dismiss button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(severityColor.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(severityColor.opacity(0.3), lineWidth: 1)
        )
    }
}
