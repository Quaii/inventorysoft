import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content

    @Environment(\.theme) var theme

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(theme.spacing.m)
            .background(theme.colors.surfaceElevated)
            .cornerRadius(theme.radii.large)
            .shadow(
                color: theme.shadows.card.color, radius: theme.shadows.card.radius,
                x: theme.shadows.card.x, y: theme.shadows.card.y)
    }
}
