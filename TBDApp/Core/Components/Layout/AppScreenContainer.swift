import SwiftUI

struct AppScreenContainer<Content: View>: View {
    let content: Content

    @Environment(\.theme) var theme

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            ZStack {
                theme.colors.backgroundPrimary
                    .ignoresSafeArea()

                // Ambient Glow 1 (Top Left)
                Circle()
                    .fill(theme.colors.accentPrimary.opacity(0.15))
                    .frame(width: 600, height: 600)
                    .blur(radius: 120)
                    .offset(x: -200, y: -200)

                // Ambient Glow 2 (Bottom Right)
                Circle()
                    .fill(theme.colors.accentSecondary.opacity(0.1))
                    .frame(width: 500, height: 500)
                    .blur(radius: 100)
                    .offset(x: 200, y: 200)
            }
            .ignoresSafeArea()

            content
                .padding(theme.spacing.xl)
        }
    }
}
