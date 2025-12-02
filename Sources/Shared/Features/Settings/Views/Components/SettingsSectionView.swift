import SwiftUI

/// Reusable section container for Settings page
struct SettingsSectionView<Content: View>: View {
    let title: String
    let description: String?
    let content: Content

    init(
        title: String,
        description: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                if let description = description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Section Content
            VStack(spacing: 0) {
                content
            }
        }
        .padding(24)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(16)
    }
}
