import SwiftUI

struct AppSidebarContainer<Sidebar: View, Content: View>: View {
    let sidebar: Sidebar
    let content: Content

    init(@ViewBuilder sidebar: () -> Sidebar, @ViewBuilder content: () -> Content) {
        self.sidebar = sidebar()
        self.content = content()
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            content
        }
    }
}
