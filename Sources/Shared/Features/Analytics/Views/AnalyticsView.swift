import Charts
import SwiftUI

#if os(macOS)
    import AppKit
#endif

struct AnalyticsView: View {
    @StateObject var viewModel: AnalyticsViewModel
    @Environment(\.theme) var theme
    @State private var timeRange: String = "Last 30 Days"

    // Edit mode state
    @State private var isEditMode = false

    // Custom UI state for modals
    @State private var showingAddWidget = false
    @State private var showingContextMenu = false
    @State private var contextMenuWidget: UserWidget?
    @State private var contextMenuPosition: CGPoint = .zero

    var body: some View {
        AppScreenContainer {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Analytics",
                    title: "Analytics",
                    subtitle: "Deep dive into your business metrics"
                ) {
                    HStack(spacing: theme.spacing.s) {
                        AppDropdown(
                            options: ["Last 7 Days", "Last 30 Days", "This Year"],
                            selection: $timeRange
                        )
                        .frame(width: 160)

                        // Edit Mode Toggle
                        AppButton(
                            title: isEditMode ? "Done" : "Edit",
                            icon: isEditMode ? "checkmark" : "pencil",
                            style: isEditMode ? .primary : .secondary
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                isEditMode.toggle()
                            }
                        }

                        AppButton(title: "Add Chart", icon: "plus", style: .secondary) {
                            showingAddWidget = true
                        }
                    }
                }

                // Content
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let error = viewModel.errorMessage {
                    AppEmptyStateView(
                        title: "Error Loading Charts",
                        message: error,
                        icon: "exclamationmark.triangle",
                        actionTitle: "Retry",
                        action: {
                            Task { await viewModel.loadWidgets() }
                        }
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: theme.layout.sectionSpacing) {
                            // Section Header
                            HStack {
                                Text("My Charts")
                                    .font(theme.typography.sectionTitle)
                                    .foregroundColor(theme.colors.textPrimary)

                                Spacer()

                                if isEditMode {
                                    Text("Tap to remove • Drag to rearrange")
                                        .font(theme.typography.caption)
                                        .foregroundColor(theme.colors.accentPrimary)
                                } else {
                                    Text(
                                        "\(viewModel.widgets.count) chart\(viewModel.widgets.count == 1 ? "" : "s")"
                                    )
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                                }
                            }

                            // Charts Grid or Empty State
                            if viewModel.widgets.isEmpty {
                                // Empty State
                                VStack(spacing: theme.spacing.xl) {
                                    Image(systemName: "chart.bar.xaxis")
                                        .font(.system(size: 64))
                                        .foregroundColor(theme.colors.textSecondary.opacity(0.3))

                                    VStack(spacing: theme.spacing.xs) {
                                        Text("No charts yet")
                                            .font(theme.typography.sectionTitle)
                                            .foregroundColor(theme.colors.textPrimary)

                                        Text(
                                            "Click 'Add Chart' to create your first analytics widget"
                                        )
                                        .font(theme.typography.body)
                                        .foregroundColor(theme.colors.textSecondary)
                                    }

                                    AppButton(
                                        title: "Add Chart",
                                        icon: "plus",
                                        style: .primary
                                    ) {
                                        showingAddWidget = true
                                    }
                                    .frame(maxWidth: 200)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, theme.spacing.xxl)
                                .background(theme.colors.backgroundSecondary)
                                .cornerRadius(theme.radii.medium)
                            } else {
                                // Shared Widget Grid
                                WidgetGrid(
                                    items: viewModel.widgets,
                                    isEditing: isEditMode,
                                    content: { widget in
                                        WidgetTileView(
                                            title: widget.name,
                                            icon: widget.type.icon,
                                            size: widget.size,
                                            isEditing: isEditMode,
                                            onRemove: { viewModel.removeWidget(widget) },
                                            onContextMenu: { point in
                                                if !isEditMode {
                                                    contextMenuWidget = widget
                                                    contextMenuPosition = point
                                                    showingContextMenu = true
                                                }
                                            }
                                        ) {
                                            widgetContent(for: widget)
                                        }
                                        .gridCellColumns(widget.size.columnSpan)
                                        .frame(height: theme.layout.analyticsChartCardHeight)
                                        .onTapGesture {
                                            if !isEditMode {
                                                print("Tapped chart widget: \(widget.name)")
                                            }
                                        }
                                    },
                                    onReorder: { from, to in
                                        viewModel.reorderWidgets(from: from, to: to)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, theme.layout.horizontalPadding)
                        .padding(.bottom, theme.layout.sectionSpacing)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .task {
            await viewModel.loadWidgets()
        }
        .overlay {
            // Shared Widget Context Menu
            if showingContextMenu, let widget = contextMenuWidget {
                WidgetContextMenuOverlay(
                    isPresented: $showingContextMenu,
                    widget: widget,
                    position: contextMenuPosition,
                    onConfigure: {
                        // Open chart editor
                        print("Edit chart: \(widget.name)")
                    },
                    onDuplicate: {
                        viewModel.duplicateWidget(widget)
                    },
                    onChangeSize: { newSize in
                        viewModel.changeWidgetSize(widget, to: newSize)
                    },
                    onRemove: {
                        viewModel.removeWidget(widget)
                    }
                )
            }
        }
        .overlay {
            // Add Widget Modal
            if showingAddWidget {
                AddWidgetModal(
                    isPresented: $showingAddWidget,
                    onAddWidget: { type, size, name in
                        viewModel.addWidget(type: type, size: size, name: name)
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func widgetContent(for widget: UserWidget) -> some View {
        // Parse configuration to get chart definition if available
        if let configData = widget.configuration,
            let chartDef = try? JSONDecoder().decode(ChartDefinition.self, from: configData)
        {

            // Render the chart using AppChart
            AppChart(
                title: widget.name,
                chartType: chartDef.chartType,
                data: [],  // Data loading is handled by AppChart or we need to pass it
                valueFormatter: { value in
                    // Simple formatter, could be enhanced based on metric
                    return String(format: "%.0f", value)
                }
            )
        } else {
            // Fallback for widgets without valid configuration
            VStack(spacing: theme.spacing.m) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 32))
                    .foregroundColor(theme.colors.textSecondary.opacity(0.5))

                Text("Chart not configured")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)

                Text("Right-click and select 'Edit Chart' to configure")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct AnalyticsView_Previews: PreviewProvider {
        static var previews: some View {
            AnalyticsView(
                viewModel: AnalyticsViewModel(
                    widgetRepository: AnalyticsWidgetRepository(),
                    analyticsService: AnalyticsService(
                        itemRepository: ItemRepository(),
                        salesRepository: SalesRepository()
                    )
                )
            )
            .environment(\.theme, Theme(mode: .light))
        }
    }
#endif
