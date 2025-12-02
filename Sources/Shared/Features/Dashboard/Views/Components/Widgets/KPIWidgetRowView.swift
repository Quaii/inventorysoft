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
                    .adaptive(minimum: 160, maximum: .infinity), spacing: 16)
            ],
            spacing: 16
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
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Label(widget.name, systemImage: widget.type.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    if isLoading {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondary.opacity(0.1))
                            .frame(width: 60, height: 24)
                            .shimmering()
                    } else {
                        Text(value)
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text("This Month")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
        }
        .frame(height: 100)
    }
}

// Simple shimmer extension if not available
extension View {
    func shimmering() -> some View {
        self.opacity(0.5)  // Placeholder
    }
}
