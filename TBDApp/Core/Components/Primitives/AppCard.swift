import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content
    var padding: CGFloat?

    @Environment(\.theme) var theme

    init(padding: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding ?? theme.spacing.l)
            .background(theme.colors.surfacePrimary)
            .cornerRadius(theme.radii.card)
            .shadow(
                color: theme.shadows.card.color,
                radius: theme.shadows.card.radius,
                x: theme.shadows.card.x,
                y: theme.shadows.card.y
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.card)
                    .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
            )
    }
}
