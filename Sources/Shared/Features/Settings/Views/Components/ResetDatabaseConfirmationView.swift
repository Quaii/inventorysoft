import SwiftUI

/// Custom confirmation overlay for Reset Database action
struct ResetDatabaseConfirmationView: View {
    @Binding var isPresented: Bool
    @Binding var confirmationText: String
    let onConfirm: () -> Void

    @Environment(\.theme) var theme

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Confirmation dialog
            VStack(alignment: .leading, spacing: theme.spacing.l) {
                // Title
                Text("Reset Database")
                    .font(theme.typography.sectionTitle)
                    .foregroundColor(theme.colors.error)

                // Warning message
                VStack(alignment: .leading, spacing: theme.spacing.s) {
                    Text("This action will permanently delete:")
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textPrimary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• All inventory items")
                        Text("• All sales records")
                        Text("• All purchase records")
                        Text("• All images and attachments")
                        Text("• All custom fields")
                        Text("• All settings")
                    }
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)

                    Text("This action cannot be undone.")
                        .font(theme.typography.body)
                        .bold()
                        .foregroundColor(theme.colors.error)
                        .padding(.top, theme.spacing.s)
                }

                Divider()
                    .overlay(theme.colors.divider)

                // Confirmation input
                VStack(alignment: .leading, spacing: theme.spacing.s) {
                    Text("Type RESET to confirm:")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)

                    TextField("", text: $confirmationText)
                        .textFieldStyle(.plain)
                        .padding(theme.spacing.s)
                        .background(theme.colors.backgroundSecondary)
                        .cornerRadius(theme.radii.small)
                        .font(theme.typography.body)
                }

                // Action buttons
                HStack(spacing: theme.spacing.m) {
                    AppButton(
                        title: "Cancel",
                        style: .secondary
                    ) {
                        isPresented = false
                        confirmationText = ""
                    }

                    AppButton(
                        title: "Reset Database",
                        style: .destructive
                    ) {
                        onConfirm()
                        isPresented = false
                        confirmationText = ""
                    }
                    .disabled(confirmationText != "RESET")
                    .opacity(confirmationText == "RESET" ? 1.0 : 0.5)
                }
            }
            .padding(theme.spacing.xl)
            .frame(maxWidth: 500)
            .background(theme.colors.surfaceElevated)
            .cornerRadius(theme.radii.large)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
}
