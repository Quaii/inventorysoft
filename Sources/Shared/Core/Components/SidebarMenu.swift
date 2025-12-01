import SwiftUI

struct SidebarMenu: View {
    @Binding var selectedTab: AppTab
    var namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Main Section
            VStack(spacing: 4) {
                ForEach(AppTab.allCases) { tab in
                    SidebarMenuItem(
                        title: tab.title,
                        icon: tab.icon,
                        isSelected: selectedTab == tab,
                        namespace: namespace
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTab = tab
                        }
                    }
                }
            }
        }
    }
}

struct SidebarMenuItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var namespace: Namespace.ID
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon)
                    .foregroundColor(isSelected ? .accentColor : .primary)
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
