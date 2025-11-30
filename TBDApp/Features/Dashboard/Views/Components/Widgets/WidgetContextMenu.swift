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
                .padding(.horizontal, theme.spacing.s)

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
                .padding(.horizontal, theme.spacing.s)

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
                .padding(.horizontal, theme.spacing.s)

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
        .background(theme.colors.backgroundPrimary)
        .cornerRadius(theme.radii.medium)
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
            HStack(spacing: theme.spacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(theme.typography.body)
                    .foregroundColor(textColor)

                Spacer()
            }
            .padding(.horizontal, theme.spacing.m)
            .padding(.vertical, theme.spacing.s)
            .background(isHovered ? theme.colors.backgroundSecondary : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var iconColor: Color {
        isDestructive ? .red : theme.colors.textSecondary
    }

    private var textColor: Color {
        isDestructive ? .red : theme.colors.textPrimary
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
                HStack(spacing: theme.spacing.m) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(width: 20, height: 20)

                    Text(title)
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(theme.colors.textSecondary)
                }
                .padding(.horizontal, theme.spacing.m)
                .padding(.vertical, theme.spacing.s)
                .background(
                    isHovered || showSubmenu ? theme.colors.backgroundSecondary : Color.clear)
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
                                    .font(theme.typography.body)
                                    .foregroundColor(theme.colors.textPrimary)

                                Spacer()

                                if size == currentSize {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12))
                                        .foregroundColor(theme.colors.accentPrimary)
                                }
                            }
                            .padding(.horizontal, theme.spacing.m)
                            .padding(.vertical, theme.spacing.s)
                            .background(Color.clear)
                        }
                        .buttonStyle(.plain)

                        if size != .large {
                            Divider()
                                .padding(.horizontal, theme.spacing.s)
                        }
                    }
                }
                .background(theme.colors.backgroundPrimary)
                .cornerRadius(theme.radii.medium)
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
            Color.clear
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
