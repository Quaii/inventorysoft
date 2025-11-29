import SwiftUI

enum AppButtonStyle {
    case primary
    case secondary
    case ghost
}

struct AppButton: View {
    let title: String
    var icon: String? = nil
    var style: AppButtonStyle = .primary
    var action: () -> Void

    @Environment(\.theme) var theme

    var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(theme.typography.bodyM)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, theme.spacing.m)
            .padding(.vertical, theme.spacing.s)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(theme.radii.medium)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return theme.colors.accentPrimary
        case .secondary: return theme.colors.surfaceElevated
        case .ghost: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return theme.colors.textPrimary
        case .ghost: return theme.colors.accentPrimary
        }
    }
}
