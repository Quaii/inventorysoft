import SwiftUI

struct SidebarHeader: View {
    var body: some View {
        HStack {
            Label("Nextmove", systemImage: "sparkles")
                .font(.headline)

            Spacer()

            SwiftUI.Button(action: {}) {
                Image(systemName: "sidebar.left")
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    SidebarHeader()
        .background(Color.black)
}
