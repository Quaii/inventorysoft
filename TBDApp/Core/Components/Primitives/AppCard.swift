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
            .background(
                ZStack {
                    // Base Layer
                    theme.colors.surfacePrimary

                    // Subtle Top Highlight (simulating light source)
                    VStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.0),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 1)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: theme.radii.medium))
                }
            )
            .cornerRadius(theme.radii.medium)
            .shadow(
                color: Color.black.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.medium)
                    .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
            )
    }
}
