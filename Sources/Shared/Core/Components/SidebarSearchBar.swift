import SwiftUI

struct SidebarSearchBar: View {
    @State private var searchText = ""

    var body: some View {
        TextField("Search...", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
    }
}

#Preview {
    SidebarSearchBar()
        .background(Color.black)
        .padding()
}
