import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content

    @Environment(\.theme) var theme

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(theme.spacing.l)
            .background(
                ZStack {
                    // Glass background
                    theme.colors.surfacePrimary
                        .blur(radius: 0)  // Placeholder for potential blur material if needed

                    // Subtle gradient overlay for depth
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.0),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(theme.radii.medium)
            .shadow(
                color: theme.shadows.card.color,
                radius: theme.shadows.card.radius,
                x: theme.shadows.card.x,
                y: theme.shadows.card.y
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.medium)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                theme.colors.borderSubtle,
                                theme.colors.borderSubtle.opacity(0.1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
