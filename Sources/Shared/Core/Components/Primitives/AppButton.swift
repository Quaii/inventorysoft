import SwiftUI

enum AppButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
    case accent
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
                .font(.system(size: 14, weight: .semibold))
                .padding(.vertical, theme.spacing.s)
                .padding(.horizontal, theme.spacing.l)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(borderColor, lineWidth: 1)
                )
                .scaleEffect(isHovering ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            self.isHovering = hovering
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return theme.colors.accentPrimary  // White pill
        case .accent:
            return theme.colors.accentTertiary
        case .secondary:
            return Color.clear  // Outline style
        case .ghost:
            return isHovering ? theme.colors.surfaceElevated : Color.clear
        case .destructive:
            return theme.colors.error.opacity(isHovering ? 0.9 : 1.0)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return theme.colors.textInversePrimary  // Black text on white
        case .accent, .destructive:
            return theme.colors.textInversePrimary
        case .secondary:
            return theme.colors.textPrimary  // White text on outline
        case .ghost:
            return theme.colors.textSecondary
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary:
            return theme.colors.buttonBorder
        case .ghost, .primary, .accent, .destructive:
            return .clear
        }
    }

    private var shadowColor: Color {
        return .clear  // Removed glow shadows
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
                Text(title)
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
