import SwiftUI

#if os(macOS)
    import AppKit
#endif

/// Grid layout for user-added dashboard widgets
struct DashboardWidgetGrid<Content: View>: View {
    let widgets: [UserWidget]
    let onWidgetTap: (UserWidget) -> Void
    let onWidgetRemove: (UserWidget) -> Void
    let onWidgetContextMenu: (UserWidget, CGPoint) -> Void
    @ViewBuilder let content: (UserWidget) -> Content

    private let columns = [
        GridItem(.adaptive(minimum: 360), spacing: 32)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Section Header
            HStack {
                Text("My Widgets")
                    .font(.title2)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(widgets.count) widget\(widgets.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if widgets.isEmpty {
                // Empty State
                ContentUnavailableView {
                    Label("No Widgets", systemImage: "square.grid.2x2")
                } description: {
                    Text("Add widgets to customize your dashboard")
                } actions: {
                    // Actions can be added here if needed, e.g. "Add Widget" button
                }
            } else {
                // Widget Grid (normal mode)
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(widgets) { widget in
                        DashboardWidgetCard(
                            widget: widget,
                            onTap: { onWidgetTap(widget) },
                            onRemove: { onWidgetRemove(widget) },
                            onContextMenu: { point in
                                onWidgetContextMenu(widget, point)
                            },
                            content: { content(widget) }
                        )
                    }
                }
            }
        }
    }
}

/// Individual widget card container
struct DashboardWidgetCard<Content: View>: View {
    let widget: UserWidget
    let onTap: () -> Void
    let onRemove: () -> Void
    let onContextMenu: (CGPoint) -> Void
    @ViewBuilder let content: () -> Content

    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            GroupBox {
                VStack(alignment: .leading, spacing: 0) {
                    // Widget Header
                    HStack {
                        Image(systemName: widget.type.icon)
                            .font(.system(size: 14))
                            .foregroundColor(.blue)

                        Text(widget.name)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding(.bottom, 8)

                    Divider()

                    // Widget Content
                    content()
                        .padding(.top, 8)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onContextMenu(.zero)
            } label: {
                Label("Configure", systemImage: "slider.horizontal.3")
            }

            Button(role: .destructive, action: onRemove) {
                Label("Remove", systemImage: "trash")
            }
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Widget Content Types

struct ListWidgetContent: View {
    let type: DashboardWidgetType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Text("Item \(index + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("--")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct StatWidgetContent: View {
    let type: DashboardWidgetType

    var body: some View {
        VStack(spacing: 4) {
            Text("$--")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CustomWidgetContent: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "function")
                .font(.system(size: 28))
                .foregroundColor(Color.blue.opacity(0.5))

            Text("Custom formula")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
