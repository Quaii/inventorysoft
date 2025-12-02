import SwiftUI

/// Unified modal for creating or editing analytics charts
struct ChartEditorView: View {
    let chart: ChartDefinition?  // nil = create mode, non-nil = edit mode
    let onSave: (ChartDefinition) -> Void
    @Binding var isPresented: Bool

    @Environment(\.theme) var theme

    // Form fields
    @State private var title: String
    @State private var chartType: ChartType
    @State private var dataSource: ChartDataSource
    @State private var yField: String
    @State private var aggregation: ChartAggregation
    @State private var colorPalette: String
    @State private var hasFormula: Bool
    @State private var formulaOperation: FormulaOperation
    @State private var formulaField1: String
    @State private var formulaField2: String

    init(
        chart: ChartDefinition?, onSave: @escaping (ChartDefinition) -> Void,
        isPresented: Binding<Bool>
    ) {
        self.chart = chart
        self.onSave = onSave
        self._isPresented = isPresented

        // Initialize state from chart or defaults
        _title = State(initialValue: chart?.title ?? "")
        _chartType = State(initialValue: chart?.chartType ?? .bar)
        _dataSource = State(initialValue: chart?.dataSource ?? .sales)
        _yField = State(initialValue: chart?.yField ?? "soldPrice")
        _aggregation = State(initialValue: chart?.aggregation ?? .sum)
        _colorPalette = State(initialValue: chart?.colorPalette ?? "default")
        _hasFormula = State(initialValue: chart?.formula != nil)
        _formulaOperation = State(initialValue: chart?.formula?.operation ?? .subtract)
        _formulaField1 = State(initialValue: chart?.formula?.field1 ?? "")
        _formulaField2 = State(initialValue: chart?.formula?.field2 ?? "")
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var mode: String {
        chart == nil ? "Create" : "Edit"
    }

    var body: some View {
        NavigationStack {
            Form {
                chartNameSection
                chartTypeSection
                dataSourceSection
                metricFieldSection
                aggregationSection
                customFormulaSection
                colorPaletteSection
            }
            .navigationTitle("\(mode) Chart")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode == "Create" ? "Create" : "Save") {
                        saveChart()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var chartNameSection: some View {
        Section("Chart Name") {
            TextField("e.g., Monthly Revenue", text: $title)
        }
    }

    private var chartTypeSection: some View {
        Section("Chart Type") {
            Picker("Chart Type", selection: $chartType) {
                ForEach([ChartType.bar, .line, .area, .donut], id: \.self) { type in
                    Label(type.rawValue.capitalized, systemImage: type.icon)
                        .tag(type)
                }
            }
        }
    }

    private var dataSourceSection: some View {
        Section("Data Source") {
            Picker("Data Source", selection: $dataSource) {
                ForEach(ChartDataSource.allCases, id: \.self) { source in
                    Text(source.displayName).tag(source)
                }
            }
        }
    }

    private var metricFieldSection: some View {
        Section("Metric Field") {
            metricFieldPicker
        }
    }

    private var aggregationSection: some View {
        Section("Aggregation") {
            Picker("Aggregation", selection: $aggregation) {
                ForEach(ChartAggregation.allCases, id: \.self) { agg in
                    Text(agg.displayName).tag(agg)
                }
            }
        }
    }

    private var customFormulaSection: some View {
        Section("Custom Formula (Optional)") {
            Toggle("Use custom formula", isOn: $hasFormula)

            if hasFormula {
                TextField("Field 1", text: $formulaField1)

                Picker("Operation", selection: $formulaOperation) {
                    ForEach(FormulaOperation.allCases, id: \.self) { op in
                        Text(op.symbol).tag(op)
                    }
                }

                TextField("Field 2", text: $formulaField2)
            }
        }
    }

    private var colorPaletteSection: some View {
        Section("Color Palette") {
            Picker("Color Palette", selection: $colorPalette) {
                ForEach(["default", "blue", "green", "purple", "orange"], id: \.self) { palette in
                    HStack {
                        Text(palette.capitalized)
                        Spacer()
                        ForEach(ChartColorPalette.colors(for: palette).prefix(3), id: \.self) {
                            colorHex in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: colorHex))
                                .frame(width: 12, height: 12)
                        }
                    }
                    .tag(palette)
                }
            }
        }
    }

    @ViewBuilder
    private var metricFieldPicker: some View {
        let fields: [String] = {
            switch dataSource {
            case .sales:
                return ["soldPrice", "fees", "quantity"]
            case .purchases:
                return ["cost", "quantity"]
            case .inventory:
                return ["purchasePrice", "quantity", "status"]
            case .combined:
                return ["soldPrice", "cost", "purchasePrice"]
            }
        }()

        Picker("Metric Field", selection: $yField) {
            ForEach(fields, id: \.self) { field in
                Text(field).tag(field)
            }
        }
    }

    private func saveChart() {
        let formula: FormulaConfig? =
            hasFormula && !formulaField1.isEmpty && !formulaField2.isEmpty
            ? FormulaConfig(
                operation: formulaOperation, field1: formulaField1, field2: formulaField2) : nil

        let newChart = ChartDefinition(
            id: chart?.id ?? UUID(),
            title: title,
            chartType: chartType,
            dataSource: dataSource,
            xField: "dateSold",  // Could be configurable
            yField: yField,
            aggregation: aggregation,
            groupBy: nil,
            colorPalette: colorPalette,
            formula: formula,
            sortOrder: chart?.sortOrder ?? 0
        )

        onSave(newChart)
        isPresented = false
    }
}
