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

    init(
        style: AppButtonStyle = .primary, action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.style = style
        self.action = action
        self.label = label()
    }

    init(
        title: String, icon: String? = nil, style: AppButtonStyle = .primary,
        action: @escaping () -> Void
    ) where Label == HStack<TupleView<(Image?, Text)>> {
        self.style = style
        self.action = action
        self.label = HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(title)
        }
    }

    init(
        icon: String, style: AppButtonStyle = .primary,
        action: @escaping () -> Void
    ) where Label == Image {
        self.style = style
        self.action = action
        self.label = Image(systemName: icon)
    }

    var body: some View {
        Button(action: action) {
            label
                .font(theme.typography.bodyM)
                .fontWeight(.semibold)
                .padding(.horizontal, theme.spacing.m)
                .padding(.vertical, theme.spacing.s)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(theme.radii.medium)
        }
        .buttonStyle(.plain)  // Important for macOS to avoid default button styling
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return theme.colors.accentPrimary
        case .secondary: return theme.colors.surfaceElevated
        case .destructive: return theme.colors.error
        case .ghost: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return theme.colors.textPrimary
        case .destructive: return .white
        case .ghost: return theme.colors.accentPrimary
        }
    }
}
