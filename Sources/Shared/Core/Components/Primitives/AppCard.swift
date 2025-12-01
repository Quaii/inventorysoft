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
            .padding(padding ?? 16)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
            )
    }
}
