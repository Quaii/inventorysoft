import SwiftUI

/// ListRow - Standard list row component with consistent height and styling
/// 56px height, surface1 background, subtle stroke
struct ListRow<Content: View>: View {
    let content: Content
    let action: (() -> Void)?

    @Environment(\.theme) var theme
    @State private var isHovering = false

    init(action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    rowContent
                }
                .buttonStyle(.plain)
            } else {
                rowContent
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                self.isHovering = hovering
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            content
                .foregroundColor(.primary)
        }
        .frame(height: 56)  // Neo Noir: Standard row height
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
        )
    }
}
