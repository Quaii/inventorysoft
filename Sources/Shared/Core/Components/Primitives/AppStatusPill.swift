import SwiftUI

struct AppStatusPill: View {
    let status: ItemStatus

    @Environment(\.theme) var theme

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(theme.typography.caption)
            .fontWeight(.medium)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(foregroundColor.opacity(0.2), lineWidth: 1)
            )
    }

    private var backgroundColor: Color {
        switch status {
        case .inStock: return theme.colors.success.opacity(0.1)
        case .listed: return theme.colors.info.opacity(0.1)
        case .sold: return theme.colors.accentSecondary.opacity(0.1)
        case .reserved: return theme.colors.warning.opacity(0.1)
        case .archived: return theme.colors.surfaceMuted
        case .draft: return theme.colors.surfaceElevated
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .inStock: return theme.colors.success
        case .listed: return theme.colors.info
        case .sold: return theme.colors.accentSecondary
        case .reserved: return theme.colors.warning
        case .draft: return theme.colors.textSecondary
        case .archived: return theme.colors.textMuted
        }
    }
}
