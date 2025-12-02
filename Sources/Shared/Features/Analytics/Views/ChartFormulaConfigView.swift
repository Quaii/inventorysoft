import SwiftUI

struct ChartFormulaConfigView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var formula: FormulaConfig?

    @State private var operation: FormulaOperation = .divide
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var hasFormula: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable Custom Formula", isOn: $hasFormula)
                } header: {
                    Text("Configuration")
                } footer: {
                    Text("Perform calculations on your data")
                }

                if hasFormula {
                    Section("Formula Definition") {
                        TextField("Field 1 (e.g., soldPrice)", text: $field1)

                        Picker("Operation", selection: $operation) {
                            ForEach(FormulaOperation.allCases, id: \.self) { op in
                                HStack {
                                    Text(op.symbol)
                                    Text(op.displayName)
                                }.tag(op)
                            }
                        }

                        TextField("Field 2 (e.g., fees)", text: $field2)
                    }

                    Section("Preview") {
                        HStack {
                            Text(field1.isEmpty ? "field1" : field1)
                            Text(operation.symbol)
                            Text(field2.isEmpty ? "field2" : field2)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Custom Formula")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if hasFormula && !field1.isEmpty && !field2.isEmpty {
                            formula = FormulaConfig(
                                operation: operation, field1: field1, field2: field2)
                        } else {
                            formula = nil
                        }
                        dismiss()
                    }
                }
            }
        }
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
