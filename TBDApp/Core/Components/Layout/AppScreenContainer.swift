import SwiftUI

struct AppScreenContainer<Content: View>: View {
    let content: Content

    @Environment(\.theme) var theme

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .frame(maxWidth: 1400, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.xl)
        }
        .inventorySoftScrollStyle()
        .background(theme.colors.backgroundPrimary.ignoresSafeArea())
    }
}
