import SwiftUI

struct Sidebar: View {
    @Binding var selectedTab: AppTab
    var namespace: Namespace.ID
    @Environment(\.theme) var theme

    var body: some View {
        VStack(spacing: 0) {
            // Header
            SidebarHeader()

            // Search
            SidebarSearchBar()
                .padding(.bottom, 20)

            // Navigation
            ScrollView(showsIndicators: false) {
                SidebarMenu(selectedTab: $selectedTab, namespace: namespace)
            }

            Spacer()
        }
        .frame(width: 280)
        .background(Color.black.opacity(0.85))  // Match main content background
        .overlay(
            HStack {
                Spacer()
                Rectangle()
                    .fill(Color.gray.opacity(0.2))  // Subtle separator
                    .frame(width: 1)
            }
        )
    }
}
