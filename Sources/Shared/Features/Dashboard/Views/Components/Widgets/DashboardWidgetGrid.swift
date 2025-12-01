import SwiftUI

#if os(macOS)
    import AppKit
#endif

/// Grid layout for user-added dashboard widgets
struct DashboardWidgetGrid<Content: View>: View {
    @Environment(\.theme) var theme
    let widgets: [UserWidget]
    let isEditMode: Bool
    let onWidgetTap: (UserWidget) -> Void
    let onWidgetRemove: (UserWidget) -> Void
    let onWidgetContextMenu: (UserWidget, CGPoint) -> Void
    let onReorder: (IndexSet, Int) -> Void
    @ViewBuilder let content: (UserWidget) -> Content

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.m) {
            // Section Header
            HStack {
                Text("My Widgets")
                    .font(theme.typography.sectionTitle)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                if isEditMode {
                    Text("Tap to remove • Drag to rearrange")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.accentPrimary)
                } else {
                    Text("\(widgets.count) widget\(widgets.count == 1 ? "" : "s")")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            if widgets.isEmpty {
                // Empty State
                DashboardWidgetEmptyState()
            } else {
                if isEditMode {
                    // List mode for reordering
                    VStack(spacing: theme.spacing.m) {
                        ForEach(widgets) { widget in
                            DashboardWidgetCard(
                                widget: widget,
                                isEditMode: isEditMode,
                                onTap: { onWidgetTap(widget) },
                                onRemove: { onWidgetRemove(widget) },
                                onContextMenu: { point in
                                    onWidgetContextMenu(widget, point)
                                },
                                content: { content(widget) }
                            )
                        }
                        .onMove { source, destination in
                            onReorder(source, destination)
                        }
                    }
                } else {
                    // Widget Grid (normal mode)
                    LazyVGrid(columns: columns, spacing: theme.spacing.l) {
                        ForEach(widgets) { widget in
                            DashboardWidgetCard(
                                widget: widget,
                                isEditMode: isEditMode,
                                onTap: { onWidgetTap(widget) },
                                onRemove: { onWidgetRemove(widget) },
                                onContextMenu: { point in
                                    onWidgetContextMenu(widget, point)
                                },
                                content: { content(widget) }
                            )
                            .gridCellColumns(widget.size.columnSpan)
                        }
                    }
                }
            }
        }
    }
}

/// Empty state for widget grid
struct DashboardWidgetEmptyState: View {
    @Environment(\.theme) var theme

    var body: some View {
        VStack(spacing: theme.spacing.l) {
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 64))
                .foregroundColor(theme.colors.textSecondary.opacity(0.3))

            VStack(spacing: theme.spacing.xs) {
                Text("No widgets yet")
                    .font(theme.typography.sectionTitle)
                    .foregroundColor(theme.colors.textPrimary)

                Text("Click 'Add Widget' to create your first widget")
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(theme.colors.backgroundSecondary)
        .cornerRadius(theme.radii.medium)
    }
}

/// Individual widget card container
struct DashboardWidgetCard<Content: View>: View {
    @Environment(\.theme) var theme
    let widget: UserWidget
    let isEditMode: Bool
    let onTap: () -> Void
    let onRemove: () -> Void
    let onContextMenu: (CGPoint) -> Void
    @ViewBuilder let content: () -> Content

    @State private var isHovered = false
    @State private var wobbleOffset: CGFloat = 0

    var body: some View {
        Button(action: {
            if isEditMode {
                onRemove()
            } else {
                onTap()
            }
        }) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    // Widget Header
                    HStack {
                        Image(systemName: widget.type.icon)
                            .font(.system(size: 14))
                            .foregroundColor(theme.colors.accentSecondary)

                        Text(widget.name)
                            .font(theme.typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(theme.colors.textPrimary)

                        Spacer()

                        if isHovered && !isEditMode {
                            Button(action: onRemove) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10))
                                    .foregroundColor(theme.colors.textSecondary)
                                    .frame(width: 20, height: 20)
                                    .background(theme.colors.backgroundSecondary)
                                    .cornerRadius(theme.radii.small)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(theme.spacing.m)

                    Divider()

                    // Widget Content
                    content()
                        .padding(theme.spacing.m)
                        .opacity(isEditMode ? 0.6 : 1.0)
                }
                .background(theme.colors.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radii.medium)
                        .stroke(
                            isEditMode
                                ? theme.colors.accentPrimary.opacity(0.5)
                                : isHovered
                                    ? theme.colors.accentSecondary.opacity(0.3) : theme.colors.backgroundPrimary,
                            lineWidth: isEditMode ? 3 : 2
                        )
                )
                .cornerRadius(theme.radii.medium)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                // Delete badge in edit mode
                if isEditMode {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                        .background(Circle().fill(Color.white).frame(width: 18, height: 18))
                        .offset(x: 8, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .rotationEffect(.degrees(isEditMode ? wobbleOffset : 0))
        .animation(
            isEditMode
                ? Animation.easeInOut(duration: 0.1)
                    .repeatForever(autoreverses: true) : .default,
            value: isEditMode
        )
        .onAppear {
            if isEditMode {
                wobbleOffset = Double.random(in: -1.5...1.5)
            }
        }
        .onChange(of: isEditMode) { _, newValue in
            wobbleOffset = newValue ? Double.random(in: -1.5...1.5) : 0
        }
        .gesture(
            // Right-click gesture for context menu (only when not in edit mode)
            TapGesture(count: 1)
                .modifiers(.control)
                .onEnded { _ in
                    if !isEditMode {
                        let mouseLocation = NSEvent.mouseLocation
                        let point = CGPoint(x: mouseLocation.x, y: mouseLocation.y)
                        onContextMenu(point)
                    }
                }
        )
    }
}

// MARK: - Widget Content Types

struct ListWidgetContent: View {
    @Environment(\.theme) var theme
    let type: DashboardWidgetType

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.s) {
            ForEach(0..<3, id: \.self) { index in
                HStack {
                    Circle()
                        .fill(theme.colors.accentSecondary.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Text("Item \(index + 1)")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)

                    Spacer()

                    Text("--")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct StatWidgetContent: View {
    @Environment(\.theme) var theme
    let type: DashboardWidgetType

    var body: some View {
        VStack(spacing: theme.spacing.xs) {
            Text("$--")
                .font(theme.typography.pageTitle)
                .fontWeight(.bold)
                .foregroundColor(theme.colors.textPrimary)

            Text("Loading...")
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CustomWidgetContent: View {
    @Environment(\.theme) var theme

    var body: some View {
        VStack(spacing: theme.spacing.s) {
            Image(systemName: "function")
                .font(.system(size: 28))
                .foregroundColor(theme.colors.accentSecondary.opacity(0.5))

            Text("Custom formula")
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
