import SwiftUI

/// Custom context menu for dashboard widgets
struct WidgetContextMenu: View {
    @Environment(\.theme) var theme
    let widget: UserWidget
    let onConfigure: () -> Void
    let onDuplicate: () -> Void
    let onChangeSize: (DashboardWidgetSize) -> Void
    let onRemove: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Configure
            WidgetContextMenuItem(
                icon: "slider.horizontal.3",
                title: "Configure Widget",
                onTap: {
                    onConfigure()
                    onDismiss()
                }
            )

            Divider()
                .padding(.horizontal, 8)

            // Duplicate
            WidgetContextMenuItem(
                icon: "plus.square.on.square",
                title: "Duplicate Widget",
                onTap: {
                    onDuplicate()
                    onDismiss()
                }
            )

            Divider()
                .padding(.horizontal, 8)

            // Change Size submenu
            WidgetContextMenuSubmenu(
                icon: "arrow.up.left.and.arrow.down.right",
                title: "Change Size",
                currentSize: widget.size,
                onSizeSelect: { size in
                    onChangeSize(size)
                    onDismiss()
                }
            )

            Divider()
                .padding(.horizontal, 8)

            // Remove
            WidgetContextMenuItem(
                icon: "trash",
                title: "Remove Widget",
                isDestructive: true,
                onTap: {
                    onRemove()
                    onDismiss()
                }
            )
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .frame(width: 220)
    }
}

/// Individual context menu item
struct WidgetContextMenuItem: View {
    @Environment(\.theme) var theme
    let icon: String
    let title: String
    var isDestructive: Bool = false
    let onTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(.body)
                    .foregroundColor(textColor)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isHovered ? Color.secondary.opacity(0.1) : Color(nsColor: .windowBackgroundColor))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var iconColor: Color {
        isDestructive ? .red : .secondary
    }

    private var textColor: Color {
        isDestructive ? .red : .primary
    }
}

/// Context menu submenu for size selection
struct WidgetContextMenuSubmenu: View {
    @Environment(\.theme) var theme
    let icon: String
    let title: String
    let currentSize: DashboardWidgetSize
    let onSizeSelect: (DashboardWidgetSize) -> Void

    @State private var isHovered = false
    @State private var showSubmenu = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main item
            Button(action: { showSubmenu.toggle() }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)

                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isHovered || showSubmenu
                        ? Color.secondary.opacity(0.1) : Color(nsColor: .windowBackgroundColor))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovered = hovering
                if hovering {
                    showSubmenu = true
                }
            }

            // Submenu
            if showSubmenu {
                VStack(spacing: 0) {
                    ForEach([DashboardWidgetSize.small, .medium, .large], id: \.self) { size in
                        Button(action: { onSizeSelect(size) }) {
                            HStack {
                                Text(size.displayName)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Spacer()

                                if size == currentSize {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(nsColor: .windowBackgroundColor))
                        }
                        .buttonStyle(.plain)

                        if size != .large {
                            Divider()
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .background(Color(nsColor: .windowBackgroundColor))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .frame(width: 150)
                .offset(x: 220, y: 0)
            }
        }
    }
}

/// Context menu overlay manager
struct WidgetContextMenuOverlay: View {
    @Environment(\.theme) var theme
    @Binding var isPresented: Bool
    let widget: UserWidget
    let position: CGPoint
    let onConfigure: () -> Void
    let onDuplicate: () -> Void
    let onChangeSize: (DashboardWidgetSize) -> Void
    let onRemove: () -> Void

    var body: some View {
        ZStack {
            // Backdrop to dismiss
            Color.black.opacity(0.01)
                .contentShape(Rectangle())
                .onTapGesture {
                    isPresented = false
                }

            // Menu
            WidgetContextMenu(
                widget: widget,
                onConfigure: onConfigure,
                onDuplicate: onDuplicate,
                onChangeSize: onChangeSize,
                onRemove: onRemove,
                onDismiss: { isPresented = false }
            )
            .position(position)
        }
    }
}
