import SwiftUI

enum AppButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
    case accent  // New style for the "warm" accent if needed
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
                .font(theme.typography.bodyM.weight(.semibold))
                .padding(.vertical, theme.spacing.s)
                .padding(.horizontal, theme.spacing.l)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .clipShape(Capsule())  // Enforce pill shape
                .overlay(
                    Capsule()
                        .stroke(borderColor, lineWidth: 1)
                )
                .shadow(color: shadowColor, radius: isHovering ? 8 : 4, x: 0, y: isHovering ? 4 : 2)
                .scaleEffect(isHovering ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { isHovering in
            self.isHovering = isHovering
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return theme.colors.accentPrimary.opacity(isHovering ? 0.9 : 1.0)
        case .accent:
            return theme.colors.accentTertiary.opacity(isHovering ? 0.9 : 1.0)
        case .secondary:
            return theme.colors.surfaceElevated.opacity(isHovering ? 1.0 : 0.8)
        case .ghost:
            return isHovering ? theme.colors.surfaceElevated : Color.clear
        case .destructive:
            return theme.colors.error.opacity(isHovering ? 0.9 : 1.0)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .accent, .destructive:
            return theme.colors.textInversePrimary
        case .secondary:
            return theme.colors.textPrimary
        case .ghost:
            return theme.colors.textSecondary
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary:
            return theme.colors.borderSubtle
        case .ghost:
            return .clear
        default:
            return .white.opacity(0.1)  // Subtle inner border for primary/accent
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:
            return theme.colors.accentPrimary.opacity(0.4)
        case .accent:
            return theme.colors.accentTertiary.opacity(0.4)
        case .destructive:
            return theme.colors.error.opacity(0.4)
        default:
            return .clear
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
