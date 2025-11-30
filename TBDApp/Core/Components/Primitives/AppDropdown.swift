import SwiftUI

struct AppDropdown: View {
    let label: String?
    let placeholder: String
    let options: [String]
    @Binding var selection: String

    @Environment(\.theme) var theme
    @State private var isExpanded = false

    init(
        label: String? = nil,
        placeholder: String = "Select...",
        options: [String],
        selection: Binding<String>
    ) {
        self.label = label
        self.placeholder = placeholder
        self.options = options
        self._selection = selection
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = label {
                Text(label)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                    }) {
                        HStack {
                            Text(option)
                            if selection == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? placeholder : selection)
                        .font(theme.typography.body)
                        .foregroundColor(
                            selection.isEmpty
                                ? theme.colors.textSecondary : theme.colors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(theme.colors.textSecondary)
                }
                .padding(.horizontal, theme.spacing.m)
                .padding(.vertical, theme.spacing.s + 2)
                .background(theme.colors.surfaceSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(theme.colors.borderSubtle, lineWidth: 1)
                )
            }
            .menuStyle(.borderlessButton)
            .frame(maxWidth: .infinity)
        }
    }
}
