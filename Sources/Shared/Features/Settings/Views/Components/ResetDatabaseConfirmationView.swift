import SwiftUI

/// Custom confirmation overlay for Reset Database action
struct ResetDatabaseConfirmationView: View {
    @Binding var isPresented: Bool
    @Binding var confirmationText: String
    let onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This action will permanently delete:")
                            .font(.headline)
                        Text("• All inventory items")
                        Text("• All sales records")
                        Text("• All purchase records")
                        Text("• All images and attachments")
                        Text("• All custom fields")
                        Text("• All settings")

                        Text("This action cannot be undone.")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .padding(.top, 8)
                    }
                } header: {
                    Text("Warning")
                }

                Section {
                    TextField("Type RESET to confirm", text: $confirmationText)
                        .autocorrectionDisabled()
                        .autocorrectionDisabled()
                } header: {
                    Text("Confirmation")
                } footer: {
                    Text("Type RESET to confirm deletion")
                }
            }
            .navigationTitle("Reset Database")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        confirmationText = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Reset Database", role: .destructive) {
                        onConfirm()
                        isPresented = false
                        confirmationText = ""
                    }
                    .disabled(confirmationText != "RESET")
                }
            }
        }
        .frame(width: 500, height: 400)
    }
}
