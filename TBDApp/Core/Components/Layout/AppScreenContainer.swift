import SwiftUI

struct AppScreenContainer<Content: View>: View {
    let content: Content

    @Environment(\.theme) var theme

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            theme.colors.backgroundPrimary
                .ignoresSafeArea()

            content
                .padding(theme.spacing.m)
        }
    }
}
