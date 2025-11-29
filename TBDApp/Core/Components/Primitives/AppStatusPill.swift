import SwiftUI

struct AppStatusPill: View {
    let status: ItemStatus

    @Environment(\.theme) var theme

    var body: some View {
        Text(status.rawValue)
            .font(theme.typography.caption)
            .fontWeight(.medium)
            .padding(.horizontal, theme.spacing.s)
            .padding(.vertical, theme.spacing.xxs)
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(backgroundColor)
            .cornerRadius(theme.radii.pill)
    }

    private var backgroundColor: Color {
        switch status {
        case .inStock: return theme.colors.success
        case .listed: return theme.colors.accentSecondary
        case .sold: return theme.colors.accentPrimary
        case .reserved: return theme.colors.warning
        case .archived: return theme.colors.textSecondary
        case .draft: return theme.colors.borderSubtle
        }
    }
}
