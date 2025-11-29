import SwiftUI

struct AppStatusPill: View {
    let status: ItemStatus

    @Environment(\.theme) var theme

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(theme.typography.caption)
            .fontWeight(.semibold)
            .padding(.vertical, 4)
            .padding(.horizontal, theme.spacing.s)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(theme.radii.pill)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.pill)
                    .stroke(foregroundColor.opacity(0.3), lineWidth: 1)
            )
    }

    private var backgroundColor: Color {
        switch status {
        case .inStock: return theme.colors.success.opacity(0.15)
        case .listed: return theme.colors.accentSecondary.opacity(0.15)  // Assuming .listed should map to something, using the new sold color
        case .sold: return theme.colors.accentSecondary.opacity(0.15)
        case .reserved: return theme.colors.warning.opacity(0.15)
        case .archived: return theme.colors.surfaceMuted
        case .draft: return theme.colors.surfaceMuted
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .inStock: return theme.colors.success
        case .listed: return theme.colors.accentSecondary  // Assuming .listed should map to something, using the new sold color
        case .sold: return theme.colors.accentSecondary
        case .reserved: return theme.colors.warning
        case .draft: return theme.colors.textMuted
        case .archived: return theme.colors.textMuted
        }
    }
}
