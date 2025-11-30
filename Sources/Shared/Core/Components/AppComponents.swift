import SwiftUI

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content
    @Environment(\.theme) var theme

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: theme.radii.card)
                    .fill(theme.colors.surfaceGlass)
                    .background(.ultraThinMaterial)  // Native blur
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.card)
                    .stroke(theme.colors.borderHighlight, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Neon Button
struct NeonButton: View {
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
        Button(action: action) {
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
            .background(
                LinearGradient(
                    colors: [theme.colors.accentSecondary, theme.colors.accentInfo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(theme.radii.button)
            .shadow(color: theme.colors.accentSecondary.opacity(0.4), radius: 10, x: 0, y: 0)  // Neon Glow
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.button)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Glass Input
struct GlassInput: View {
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

            TextField(placeholder, text: $text)
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
            .scaleEffect(isHovered ? scale : 1.0)
            .brightness(isHovered ? brightness : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
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
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? opacity : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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
