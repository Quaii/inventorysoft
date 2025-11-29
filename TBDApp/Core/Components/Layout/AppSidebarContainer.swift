import SwiftUI

struct AppSidebarContainer<Sidebar: View, Content: View>: View {
    let sidebar: Sidebar
    let content: Content

    init(@ViewBuilder sidebar: () -> Sidebar, @ViewBuilder content: () -> Content) {
        self.sidebar = sidebar()
        self.content = content()
    }

    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: 0) {
            // Custom Sidebar
            VStack(spacing: 0) {
                sidebar
                    .padding(.top, theme.spacing.xl)  // Top padding for "header" area
            }
            .frame(width: 260)
            .background(theme.colors.backgroundSecondary)
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(theme.colors.borderSubtle),
                alignment: .trailing
            )

            // Main Content
            ZStack {
                theme.colors.backgroundPrimary
                    .ignoresSafeArea()

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}
