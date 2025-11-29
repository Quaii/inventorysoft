import SwiftUI

struct AppDropdown<T: Hashable>: View {
    let label: String?
    let placeholder: String
    let options: [T]
    @Binding var selection: T

    @Environment(\.theme) var theme

    init(
        label: String? = nil,
        placeholder: String = "Select",
        options: [T],
        selection: Binding<T>
    ) {
        self.label = label
        self.placeholder = placeholder
        self.options = options
        self._selection = selection
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let label = label {
                Text(label)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: { selection = option }) {
                        HStack {
                            Text(String(describing: option))
                            if selection == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(String(describing: selection))
                        .font(theme.typography.bodyM)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
                .padding(theme.spacing.m)
                .background(theme.colors.surfaceSecondary)
                .cornerRadius(theme.radii.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radii.medium)
                        .stroke(theme.colors.borderSubtle, lineWidth: 1)
                )
            }
        }
    }
}
