import SwiftUI

/// Refined settings row with generous spacing and subtle divider
struct SettingsRowView<Control: View>: View {
    let label: String
    let helpText: String?
    let control: Control
    let showDivider: Bool

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
            HStack(alignment: .center, spacing: 16) {
                // Left: Label and help text
                VStack(alignment: .leading, spacing: 6) {
                    Text(label)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    if let helpText = helpText {
                        Text(helpText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Right: Control
                control
                    .frame(minWidth: 140, alignment: .trailing)
            }
            .padding(.horizontal, 20)
            .frame(height: 64)
            .background(Color.clear)

            // Subtle divider
            if showDivider {
                Divider()
                    .background(Color(nsColor: .separatorColor))
            }
        }
    }
}
