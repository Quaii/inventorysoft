import SwiftUI

// Card moved to separate file

// MARK: - SimpleButton
struct SimpleButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    @Environment(\.theme) var theme

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        SwiftUI.Button(action: action) {
            HStack(spacing: theme.spacing.s) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                }
                Text(title)
                    .font(theme.typography.buttonLabel)
            }
            .foregroundColor(theme.colors.textInversePrimary)
            .padding(.horizontal, theme.spacing.l)
            .padding(.vertical, theme.spacing.m)
            .background(theme.colors.accentPrimary)
            .cornerRadius(theme.radii.button)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SimpleTextField
struct SimpleTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: theme.spacing.m) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(theme.colors.textSecondary)
            }

            SwiftUI.TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textPrimary)
        }
        .padding(theme.spacing.m)
        .background(
            RoundedRectangle(cornerRadius: theme.radii.input)
                .fill(theme.colors.surfaceElevated.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.input)
                .stroke(theme.colors.borderSubtle, lineWidth: 1)
        )
    }
}
// MARK: - Interaction Modifiers

struct HoverEffectModifier: ViewModifier {
    let scale: CGFloat
    let brightness: Double
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
        // All hover effects removed for minimal UI
    }
}

struct PressEffectModifier: ViewModifier {
    let scale: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .buttonStyle(InteractiveButtonStyle(scale: scale, opacity: opacity))
    }
}

struct InteractiveButtonStyle: ButtonStyle {
    let scale: CGFloat
    let opacity: Double

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        // All press effects removed for minimal UI
    }
}

extension View {
    /// Adds a scale and brightness effect on hover (macOS/iPadOS with pointer)
    func hoverEffect(scale: CGFloat = 1.02, brightness: Double = 0.1) -> some View {
        modifier(HoverEffectModifier(scale: scale, brightness: brightness))
    }

    /// Adds a scale and dim effect on press (requires the view to be a Button or inside one to work fully as a style,
    /// or use .onTapGesture with state for custom views)
    /// Note: This modifier applies a ButtonStyle, so it should be used on Buttons.
    func pressEffect(scale: CGFloat = 0.95, opacity: Double = 0.8) -> some View {
        modifier(PressEffectModifier(scale: scale, opacity: opacity))
    }
}
