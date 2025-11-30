import SwiftUI

/// Refined settings row with generous spacing and subtle divider
struct SettingsRowView<Control: View>: View {
    let label: String
    let helpText: String?
    let control: Control
    let showDivider: Bool

    @Environment(\.theme) var theme

    init(
        label: String,
        helpText: String? = nil,
        showDivider: Bool = true,
        @ViewBuilder control: () -> Control
    ) {
        self.label = label
        self.helpText = helpText
        self.showDivider = showDivider
        self.control = control()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: theme.spacing.l) {
                // Left: Label and help text
                VStack(alignment: .leading, spacing: 6) {
                    Text(label)
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)

                    if let helpText = helpText {
                        Text(helpText)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Right: Control
                control
                    .frame(minWidth: 140, alignment: .trailing)
            }
            .padding(.vertical, 12)

            // Subtle divider
            if showDivider {
                Divider()
                    .background(theme.colors.borderSubtle)
            }
        }
    }
}
