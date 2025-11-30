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
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Modal content
            VStack(alignment: .leading, spacing: theme.spacing.l) {
                // Header
                HStack {
                    Text("\(mode) Chart")
                        .font(theme.typography.sectionTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: theme.spacing.l) {
                        // Chart Name
                        fieldSection(label: "Chart Name") {
                            TextField("e.g., Monthly Revenue", text: $title)
                                .textFieldStyle(.plain)
                                .padding(theme.spacing.s)
                                .background(theme.colors.backgroundSecondary)
                                .cornerRadius(6)
                                .font(theme.typography.body)
                        }

                        // Chart Type
                        fieldSection(label: "Chart Type") {
                            HStack(spacing: theme.spacing.s) {
                                ForEach([ChartType.bar, .line, .area, .donut], id: \.self) { type in
                                    chartTypeButton(type)
                                }
                            }
                        }

                        // Data Source
                        fieldSection(label: "Data Source") {
                            SettingsPickerPill(
                                selectedValue: dataSource.displayName,
                                options: ChartDataSource.allCases.map { $0.displayName }
                            ) { newValue in
                                if let source = ChartDataSource.allCases.first(where: {
                                    $0.displayName == newValue
                                }) {
                                    dataSource = source
                                }
                            }
                        }

                        // Metric/Field
                        fieldSection(label: "Metric Field") {
                            metricFieldPicker
                        }

                        // Aggregation
                        fieldSection(label: "Aggregation") {
                            SettingsPickerPill(
                                selectedValue: aggregation.displayName,
                                options: ChartAggregation.allCases.map { $0.displayName }
                            ) { newValue in
                                if let agg = ChartAggregation.allCases.first(where: {
                                    $0.displayName == newValue
                                }) {
                                    aggregation = agg
                                }
                            }
                        }

                        // Formula (optional)
                        fieldSection(label: "Custom Formula (Optional)") {
                            Toggle("Use custom formula", isOn: $hasFormula)
                                .labelsHidden()

                            if hasFormula {
                                VStack(spacing: theme.spacing.s) {
                                    HStack(spacing: theme.spacing.s) {
                                        TextField("Field 1", text: $formulaField1)
                                            .textFieldStyle(.plain)
                                            .padding(theme.spacing.s)
                                            .background(theme.colors.backgroundSecondary)
                                            .cornerRadius(6)

                                        SettingsPickerPill(
                                            selectedValue: formulaOperation.symbol,
                                            options: FormulaOperation.allCases.map { $0.symbol }
                                        ) { newValue in
                                            if let op = FormulaOperation.allCases.first(where: {
                                                $0.symbol == newValue
                                            }) {
                                                formulaOperation = op
                                            }
                                        }
                                        .frame(width: 80)

                                        TextField("Field 2", text: $formulaField2)
                                            .textFieldStyle(.plain)
                                            .padding(theme.spacing.s)
                                            .background(theme.colors.backgroundSecondary)
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }

                        // Color Palette
                        fieldSection(label: "Color Palette") {
                            HStack(spacing: theme.spacing.s) {
                                ForEach(
                                    ["default", "blue", "green", "purple", "orange"], id: \.self
                                ) { palette in
                                    colorPaletteButton(palette)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)

                // Action buttons
                HStack(spacing: theme.spacing.m) {
                    AppButton(
                        title: "Cancel",
                        style: .secondary
                    ) {
                        isPresented = false
                    }

                    AppButton(
                        title: mode == "Create" ? "Create Chart" : "Save Changes",
                        style: .primary
                    ) {
                        saveChart()
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1.0 : 0.5)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(theme.spacing.xl)
            .frame(maxWidth: 600)
            .background(theme.colors.surfaceElevated)
            .cornerRadius(theme.radii.card)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }

    @ViewBuilder
    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content)
        -> some View
    {
        VStack(alignment: .leading, spacing: theme.spacing.s) {
            Text(label)
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            content()
        }
    }

    @ViewBuilder
    private func chartTypeButton(_ type: ChartType) -> some View {
        Button(action: { chartType = type }) {
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                Text(type.rawValue.capitalized)
                    .font(theme.typography.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.s)
            .background(
                chartType == type
                    ? theme.colors.accentSecondary.opacity(0.2) : theme.colors.surfaceSecondary
            )
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        chartType == type
                            ? theme.colors.accentSecondary : theme.colors.borderSubtle,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func colorPaletteButton(_ palette: String) -> some View {
        Button(action: { colorPalette = palette }) {
            HStack(spacing: 2) {
                ForEach(ChartColorPalette.colors(for: palette).prefix(3), id: \.self) { colorHex in
                    Rectangle()
                        .fill(Color(hex: colorHex))
                        .frame(width: 12, height: 24)
                }
            }
            .padding(6)
            .background(theme.colors.surfaceSecondary)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        colorPalette == palette
                            ? theme.colors.accentSecondary : theme.colors.borderSubtle,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
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

        SettingsPickerPill(
            selectedValue: yField,
            options: fields
        ) { newValue in
            yField = newValue
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
