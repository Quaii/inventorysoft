import SwiftUI

/// Custom confirmation dialog for deleting analytics charts
struct ChartDeleteConfirmationView: View {
    @Binding var isPresented: Bool
    let chart: ChartDefinition
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
                Text("Remove chart?")
                    .font(theme.typography.sectionTitle)
                    .foregroundColor(theme.colors.textPrimary)

                // Message
                VStack(alignment: .leading, spacing: theme.spacing.s) {
                    Text(
                        "This will remove the chart '\(chart.title)' from your Analytics dashboard."
                    )
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textPrimary)

                    Text("The underlying data will not be deleted.")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }

                // Action buttons
                HStack(spacing: theme.spacing.m) {
                    AppButton(
                        title: "Cancel",
                        style: .secondary
                    ) {
                        isPresented = false
                    }

                    AppButton(
                        title: "Remove",
                        style: .destructive
                    ) {
                        onConfirm()
                        isPresented = false
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(theme.spacing.xl)
            .frame(maxWidth: 500)
            .background(theme.colors.surfaceElevated)
            .cornerRadius(theme.radii.card)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
}
