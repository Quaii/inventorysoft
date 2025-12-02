import SwiftUI

/// Custom context menu for chart cards
struct ChartContextMenu: View {
    let chart: ChartDefinition
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    @Binding var isPresented: Bool

    @State private var hoveredOption: String?

    var body: some View {
        VStack(spacing: 0) {
            menuOption(
                text: "Edit Chart...",
                icon: "pencil",
                action: {
                    onEdit()
                    isPresented = false
                }
            )

            Divider()

            menuOption(
                text: "Duplicate Chart",
                icon: "doc.on.doc",
                action: {
                    onDuplicate()
                    isPresented = false
                }
            )

            Divider()

            menuOption(
                text: "Remove Chart",
                icon: "trash",
                isDestructive: true,
                action: {
                    onDelete()
                    isPresented = false
                }
            )
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .frame(minWidth: 180)
    }

    @ViewBuilder
    private func menuOption(
        text: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(isDestructive ? .red : .primary)
                    .frame(width: 16)

                Text(text)
                    .font(.body)
                    .foregroundColor(isDestructive ? .red : .primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                hoveredOption == text ? Color.blue.opacity(0.1) : Color.clear
            )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { hovering in
            hoveredOption = hovering ? text : nil
        }
    }
}
