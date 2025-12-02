import SwiftUI

struct RecentPanelCard<Content: View>: View {
    let title: String
    let content: Content
    let onViewAll: (() -> Void)?

    @Environment(\.theme) var theme

    init(
        title: String,
        onViewAll: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.onViewAll = onViewAll
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                if let onViewAll = onViewAll {
                    Button(action: onViewAll) {
                        Text("View All")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Content
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(24)
        .frame(height: 220)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(16)
    }
}
