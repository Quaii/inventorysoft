import SwiftUI

enum AppButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
}

struct AppButton<Label: View>: View {
    let action: () -> Void
    let label: Label
    let style: AppButtonStyle

    @Environment(\.theme) var theme
    @State private var isHovering = false

    init(
        style: AppButtonStyle = .primary,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.style = style
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button(action: action) {
            label
                .padding(.vertical, theme.spacing.s)
                .padding(.horizontal, theme.spacing.l)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(theme.radii.pill)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radii.pill)
                        .stroke(borderColor, lineWidth: style == .secondary ? 1 : 0)
                )
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isHovering = isHovering
            }
        }
        .scaleEffect(isHovering ? 1.02 : 1.0)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return theme.colors.accentPrimary.opacity(isHovering ? 0.9 : 1.0)
        case .secondary: return theme.colors.surfaceSecondary.opacity(isHovering ? 0.8 : 1.0)
        case .ghost: return isHovering ? theme.colors.surfaceSecondary.opacity(0.5) : Color.clear
        case .destructive: return theme.colors.error.opacity(isHovering ? 0.9 : 1.0)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return theme.colors.textInversePrimary
        case .secondary: return theme.colors.textPrimary
        case .ghost: return theme.colors.textSecondary
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary: return theme.colors.borderSubtle
        default: return .clear
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary: return theme.colors.accentPrimary.opacity(0.3)
        default: return .clear
        }
    }
}

extension AppButton where Label == AnyView {
    init(
        title: String,
        icon: String? = nil,
        style: AppButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.style = style
        self.action = action
        self.label = AnyView(
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title).fontWeight(.semibold)
            }
        )
    }

    init(
        icon: String,
        style: AppButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.style = style
        self.action = action
        self.label = AnyView(Image(systemName: icon))
    }
}
