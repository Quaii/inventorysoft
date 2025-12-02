import Charts
import GRDB
import SwiftUI

#if os(macOS)
    import AppKit
#endif

struct SimpleChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

struct AnalyticsView: View {
    @StateObject var viewModel: AnalyticsViewModel
    @State private var timeRange: String = "Last 30 Days"

    @State private var showingAddWidget = false
    @State private var showingContextMenu = false
    @State private var contextMenuWidget: UserWidget?
    @State private var contextMenuPosition: CGPoint = .zero

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Charts Grid or Empty State
                    if viewModel.isLoading {
                        ProgressView("Loading charts...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let error = viewModel.errorMessage {
                        ContentUnavailableView {
                            Label("Error Loading Charts", systemImage: "exclamationmark.triangle")
                        } description: {
                            Text(error)
                        } actions: {
                            Button("Retry") {
                                Task { await viewModel.loadWidgets() }
                            }
                        }
                    } else if viewModel.widgets.isEmpty {
                        ContentUnavailableView {
                            Label("No Charts Yet", systemImage: "chart.bar.xaxis")
                        } description: {
                            Text("Click 'Add Chart' to create your first analytics widget")
                        } actions: {
                            Button("Add Chart") {
                                showingAddWidget = true
                            }
                        }
                        .padding(.vertical, 40)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 300), spacing: 16)],
                            spacing: 16
                        ) {
                            ForEach(viewModel.widgets) { widget in
                                GroupBox {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Label(widget.name, systemImage: widget.type.icon)
                                                .font(.headline)
                                            Spacer()
                                        }

                                        widgetContent(for: widget)
                                    }
                                    .padding(4)
                                }
                                .contextMenu {
                                    Button {
                                        // Edit chart action
                                    } label: {
                                        Label("Edit Chart", systemImage: "pencil")
                                    }

                                    Button {
                                        viewModel.duplicateWidget(widget)
                                    } label: {
                                        Label("Duplicate", systemImage: "plus.square.on.square")
                                    }

                                    Divider()

                                    Button(role: .destructive) {
                                        viewModel.removeWidget(widget)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Picker("Time Range", selection: $timeRange) {
                        Text("Last 7 Days").tag("Last 7 Days")
                        Text("Last 30 Days").tag("Last 30 Days")
                        Text("This Year").tag("This Year")
                    }
                    .frame(width: 150)

                    Button(action: { showingAddWidget = true }) {
                        Label("Add Chart", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddWidget) {
            AddWidgetModal(
                isPresented: $showingAddWidget,
                onAddWidget: { type, size, name in
                    viewModel.addWidget(type: type, size: size, name: name)
                }
            )
        }
        .task {
            await viewModel.loadWidgets()
        }
    }

    @ViewBuilder
    private func widgetContent(for widget: UserWidget) -> some View {
        if let configData = widget.configuration,
            let chartDef = try? JSONDecoder().decode(ChartDefinition.self, from: configData)
        {

            let data = getData(for: chartDef.dataSource)

            VStack(alignment: .leading, spacing: 8) {
                Text(widget.name)
                    .font(.headline)

                if data.isEmpty {
                    ContentUnavailableView("No Data", systemImage: "chart.bar.xaxis")
                        .frame(height: 200)
                } else {
                    Chart {
                        ForEach(data) { point in
                            switch chartDef.chartType {
                            case .bar:
                                BarMark(
                                    x: .value("Date", point.label),
                                    y: .value("Value", point.value)
                                )
                                .foregroundStyle(by: .value("Category", point.label))
                            case .line:
                                LineMark(
                                    x: .value("Date", point.label),
                                    y: .value("Value", point.value)
                                )
                                .foregroundStyle(by: .value("Category", point.label))
                            case .area:
                                AreaMark(
                                    x: .value("Date", point.label),
                                    y: .value("Value", point.value)
                                )
                                .foregroundStyle(by: .value("Category", point.label))
                            case .donut:
                                SectorMark(
                                    angle: .value("Value", point.value),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(by: .value("Category", point.label))
                            case .table:
                                // Fallback for table, though Chart doesn't support it directly
                                BarMark(
                                    x: .value("Date", point.label),
                                    y: .value("Value", point.value)
                                )
                            default:
                                BarMark(
                                    x: .value("Date", point.label),
                                    y: .value("Value", point.value)
                                )
                            }
                        }
                    }
                    .frame(height: 200)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
        } else {
            ContentUnavailableView {
                Label("Chart not configured", systemImage: "chart.bar")
            } description: {
                Text("Right-click to configure")
            }
            .frame(height: 200)
        }
    }

    private func getData(for source: ChartDataSource) -> [SimpleChartDataPoint] {
        // Map viewModel data to SimpleChartDataPoint based on source
        // This is a simplification. In a real app, you'd aggregate data here.
        switch source {
        case .sales:
            return viewModel.salesData.map {
                SimpleChartDataPoint(
                    label: $0.date.formatted(date: .abbreviated, time: .omitted), value: $0.amount)
            }
        case .inventory:
            // Assuming inventoryData can be mapped
            return viewModel.inventoryData.prefix(10).map {
                SimpleChartDataPoint(label: $0.title, value: Double($0.quantity))
            }
        default:
            return []
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
                    ),
                    configService: AnalyticsConfigService(
                        repository: AnalyticsConfigRepository(
                            dbQueue: DatabaseManager.shared.dbWriter as! GRDB.DatabaseQueue),
                        preferencesRepo: UserPreferencesRepository()
                    ),
                    exportService: ExportService(
                        db: DatabaseManager.shared,
                        columnConfigService: ColumnConfigService(
                            repository: ColumnConfigRepository())
                    )
                )
            )
        }
    }
#endif
