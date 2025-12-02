import SwiftUI

struct ChartMetricConfigView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    @Binding var chartDefinition: ChartDefinition

    @State private var editedDefinition: ChartDefinition

    init(chartDefinition: Binding<ChartDefinition>) {
        self._chartDefinition = chartDefinition
        self._editedDefinition = State(initialValue: chartDefinition.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Chart Title") {
                    TextField("e.g., Revenue Trend", text: $editedDefinition.title)
                }

                Section("Data Source") {
                    Picker("Data Source", selection: $editedDefinition.dataSource) {
                        ForEach(ChartDataSource.allCases, id: \.self) { source in
                            Text(source.displayName).tag(source)
                        }
                    }
                }

                Section("Fields") {
                    Picker("X-Axis", selection: $editedDefinition.xField) {
                        ForEach(availableFields(for: editedDefinition.dataSource), id: \.self) {
                            field in
                            Text(field).tag(field)
                        }
                    }

                    Picker("Y-Axis", selection: $editedDefinition.yField) {
                        ForEach(availableFields(for: editedDefinition.dataSource), id: \.self) {
                            field in
                            Text(field).tag(field)
                        }
                    }
                }

                Section("Configuration") {
                    Picker("Aggregation", selection: $editedDefinition.aggregation) {
                        ForEach(ChartAggregation.allCases, id: \.self) { agg in
                            Text(agg.displayName).tag(agg)
                        }
                    }

                    Picker(
                        "Group By (Optional)",
                        selection: Binding(
                            get: { editedDefinition.groupBy ?? "None" },
                            set: { editedDefinition.groupBy = $0 == "None" ? nil : $0 }
                        )
                    ) {
                        Text("None").tag("None")
                        ForEach(availableFields(for: editedDefinition.dataSource), id: \.self) {
                            field in
                            Text(field).tag(field)
                        }
                    }
                }
            }
            .navigationTitle("Configure Chart Metric")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        chartDefinition = editedDefinition
                        dismiss()
                    }
                }
            }
        }
    }

    // Helper function to get available fields based on data source
    private func availableFields(for source: ChartDataSource) -> [String] {
        switch source {
        case .inventory:
            return ["title", "sku", "category", "purchasePrice", "quantity", "status", "dateAdded"]
        case .sales:
            return ["platform", "soldPrice", "fees", "buyer", "dateSold"]
        case .purchases:
            return ["batchName", "supplier", "cost", "datePurchased"]
        case .combined:
            return ["date", "amount", "type"]
        }
    }
}
