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
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Configure Chart Metric")
                        .font(theme.typography.headingL)
                        .foregroundColor(theme.colors.textPrimary)

                    Text("Choose data source and fields for this chart")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(theme.spacing.l)
            .background(theme.colors.backgroundPrimary)

            Divider().overlay(theme.colors.divider)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.l) {
                    // Chart Title
                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.s) {
                            Text("CHART TITLE")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)

                            AppTextField(
                                placeholder: "e.g., Revenue Trend",
                                text: $editedDefinition.title
                            )
                        }
                    }
                    .padding(.horizontal, theme.spacing.l)

                    // Data Source
                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.s) {
                            Text("DATA SOURCE")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)

                            Picker("Data Source", selection: $editedDefinition.dataSource) {
                                ForEach(ChartDataSource.allCases, id: \.self) { source in
                                    Text(source.displayName).tag(source)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal, theme.spacing.l)

                    // X-Axis Field
                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.s) {
                            Text("X-AXIS FIELD")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)

                            Picker("X-Axis", selection: $editedDefinition.xField) {
                                ForEach(
                                    availableFields(for: editedDefinition.dataSource), id: \.self
                                ) { field in
                                    Text(field).tag(field)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding(.horizontal, theme.spacing.l)

                    // Y-Axis Field
                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.s) {
                            Text("Y-AXIS FIELD")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)

                            Picker("Y-Axis", selection: $editedDefinition.yField) {
                                ForEach(
                                    availableFields(for: editedDefinition.dataSource), id: \.self
                                ) { field in
                                    Text(field).tag(field)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding(.horizontal, theme.spacing.l)

                    // Aggregation
                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.s) {
                            Text("AGGREGATION")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)

                            Picker("Aggregation", selection: $editedDefinition.aggregation) {
                                ForEach(ChartAggregation.allCases, id: \.self) { agg in
                                    Text(agg.displayName).tag(agg)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding(.horizontal, theme.spacing.l)

                    // Group By (Optional)
                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.s) {
                            Text("GROUP BY (OPTIONAL)")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)

                            Picker(
                                "Group By",
                                selection: Binding(
                                    get: { editedDefinition.groupBy ?? "None" },
                                    set: { editedDefinition.groupBy = $0 == "None" ? nil : $0 }
                                )
                            ) {
                                Text("None").tag("None")
                                ForEach(
                                    availableFields(for: editedDefinition.dataSource), id: \.self
                                ) { field in
                                    Text(field).tag(field)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding(.horizontal, theme.spacing.l)
                }
                .padding(.vertical, theme.spacing.l)
            }

            // Footer
            Divider().overlay(theme.colors.divider)

            HStack {
                AppButton(title: "Cancel", style: .ghost) {
                    dismiss()
                }

                Spacer()

                AppButton(title: "Save Changes", style: .primary) {
                    chartDefinition = editedDefinition
                    dismiss()
                }
            }
            .padding(theme.spacing.l)
            .background(theme.colors.backgroundPrimary)
        }
        .frame(width: 500, height: 700)
        .background(theme.colors.backgroundPrimary)
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
