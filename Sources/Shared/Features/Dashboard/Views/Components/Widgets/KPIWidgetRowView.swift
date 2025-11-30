import SwiftUI

struct KPIWidgetRowView: View {
    @Environment(\.theme) var theme
    let widgets: [UserWidget]
    let kpiData: [DashboardWidgetType: String]  // Map widget type to value string
    let isLoading: Bool

    // Max 4 widgets as per requirement
    private var displayWidgets: [UserWidget] {
        Array(widgets.prefix(4))
    }

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: 160, maximum: .infinity), spacing: theme.layout.cardSpacing)
            ],
            spacing: theme.layout.cardSpacing
        ) {
            ForEach(displayWidgets) { widget in
                KPIWidgetCard(
                    widget: widget,
                    value: kpiData[widget.type] ?? "—",
                    isLoading: isLoading
                )
            }
        }
    }
}

struct KPIWidgetCard: View {
    @Environment(\.theme) var theme
    let widget: UserWidget
    let value: String
    let isLoading: Bool

    var body: some View {
        WidgetTileView(
            title: widget.name,
            icon: widget.type.icon,
            size: .small,
            isEditing: false,  // KPIs are configured via settings, not inline edit
            onRemove: {},
            onContextMenu: { _ in }
        ) {
            VStack(alignment: .leading, spacing: 4) {
                if isLoading {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.colors.surfaceElevated)
                        .frame(width: 60, height: 24)
                        .shimmering()  // Assuming shimmering modifier exists or just static
                } else {
                    Text(value)
                        .font(theme.typography.headingL)
                        .foregroundColor(theme.colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    // Optional secondary label (e.g. "This month")
                    // We could add this to the model later if needed
                    Text("This Month")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
        }
        .frame(height: 100)  // Fixed height for KPI row
    }
}

// Simple shimmer extension if not available
extension View {
    func shimmering() -> some View {
        self.opacity(0.5)  // Placeholder
    }
}
