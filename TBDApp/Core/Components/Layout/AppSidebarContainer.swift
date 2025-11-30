import SwiftUI

struct AppSidebarContainer<Sidebar: View, Content: View>: View {
    let sidebar: (Bool) -> Sidebar
    let content: Content

    @State private var isCollapsed = false

    init(@ViewBuilder sidebar: @escaping (Bool) -> Sidebar, @ViewBuilder content: () -> Content) {
        self.sidebar = sidebar
        self.content = content()
    }

    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: 0) {
            // Custom Sidebar
            VStack(spacing: 0) {
                sidebar(isCollapsed)
                    .padding(.top, theme.spacing.xl)  // Top padding for "header" area

                Spacer()

                // Collapse Toggle
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isCollapsed.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: isCollapsed ? "chevron.right" : "chevron.left")
                            .foregroundColor(theme.colors.textSecondary)
                        if !isCollapsed {
                            Text("Collapse")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: isCollapsed ? .center : .leading)
                }
                .buttonStyle(.plain)
                .padding(.bottom, theme.spacing.m)
            }
            .frame(width: isCollapsed ? 60 : 220)
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
