import SwiftUI

/// Custom context menu for chart cards
struct ChartContextMenu: View {
    let chart: ChartDefinition
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    @Binding var isPresented: Bool

    @Environment(\.theme) var theme
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

            Divider().background(theme.colors.borderSubtle)

            menuOption(
                text: "Duplicate Chart",
                icon: "doc.on.doc",
                action: {
                    onDuplicate()
                    isPresented = false
                }
            )

            Divider().background(theme.colors.borderSubtle)

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
        .background(theme.colors.surfaceElevated)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(4)
        .frame(minWidth: 180)
    }

    @ViewBuilder
    private func menuOption(
        text: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.s) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(isDestructive ? theme.colors.error : theme.colors.textPrimary)
                    .frame(width: 16)

                Text(text)
                    .font(theme.typography.body)
                    .foregroundColor(isDestructive ? theme.colors.error : theme.colors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                hoveredOption == text ? theme.colors.highlight : theme.colors.backgroundPrimary
            )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { hovering in
            hoveredOption = hovering ? text : nil
        }
    }
}
