import SwiftUI

struct ChartFormulaConfigView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    @Binding var formula: FormulaConfig?

    @State private var operation: FormulaOperation = .divide
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var hasFormula: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Custom Formula")
                        .font(theme.typography.headingL)
                        .foregroundColor(theme.colors.textPrimary)

                    Text("Define a custom formula for this chart")
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
                    // Enable Formula Toggle
                    AppCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Custom Formula")
                                    .font(theme.typography.cardTitle)
                                    .foregroundColor(theme.colors.textPrimary)
                                Text("Perform calculations on your data")
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                            }

                            Spacer()

                            Toggle("", isOn: $hasFormula)
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal, theme.spacing.l)

                    if hasFormula {
                        // Field 1
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.s) {
                                Text("FIELD 1")
                                    .font(theme.typography.tableHeader)
                                    .foregroundColor(theme.colors.textSecondary)

                                AppTextField(
                                    placeholder: "e.g., soldPrice",
                                    text: $field1
                                )
                            }
                        }
                        .padding(.horizontal, theme.spacing.l)

                        // Operation
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.s) {
                                Text("OPERATION")
                                    .font(theme.typography.tableHeader)
                                    .foregroundColor(theme.colors.textSecondary)

                                Picker("Operation", selection: $operation) {
                                    ForEach(FormulaOperation.allCases, id: \.self) { op in
                                        HStack {
                                            Text(op.symbol)
                                            Text(op.displayName)
                                        }.tag(op)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                        .padding(.horizontal, theme.spacing.l)

                        // Field 2
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.s) {
                                Text("FIELD 2")
                                    .font(theme.typography.tableHeader)
                                    .foregroundColor(theme.colors.textSecondary)

                                AppTextField(
                                    placeholder: "e.g., fees",
                                    text: $field2
                                )
                            }
                        }
                        .padding(.horizontal, theme.spacing.l)

                        // Formula Preview
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.s) {
                                Text("FORMULA PREVIEW")
                                    .font(theme.typography.tableHeader)
                                    .foregroundColor(theme.colors.textSecondary)

                                HStack {
                                    Text(field1.isEmpty ? "field1" : field1)
                                        .font(theme.typography.bodyL)
                                    Text(operation.symbol)
                                        .font(theme.typography.bodyL)
                                    Text(field2.isEmpty ? "field2" : field2)
                                        .font(theme.typography.bodyL)
                                }
                                .foregroundColor(theme.colors.textSecondary)
                            }
                        }
                        .padding(.horizontal, theme.spacing.l)
                    }
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

                AppButton(title: "Save Formula", style: .primary) {
                    if hasFormula && !field1.isEmpty && !field2.isEmpty {
                        formula = FormulaConfig(
                            operation: operation, field1: field1, field2: field2)
                    } else {
                        formula = nil
                    }
                    dismiss()
                }
            }
            .padding(theme.spacing.l)
            .background(theme.colors.backgroundPrimary)
        }
        .frame(width: 500, height: 650)
        .background(theme.colors.backgroundPrimary)
        .onAppear {
            if let existingFormula = formula {
                hasFormula = true
                operation = existingFormula.operation
                field1 = existingFormula.field1
                field2 = existingFormula.field2
            }
        }
    }
}
