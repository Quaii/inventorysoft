import SwiftUI

/// Custom pill-style picker button for Settings controls
struct SettingsPickerPill: View {
    let selectedValue: String
    let options: [String]
    let onSelect: (String) -> Void

    @Environment(\.theme) var theme
    @State private var isHovered = false

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    onSelect(option)
                }) {
                    HStack {
                        Text(option)
                        if option == selectedValue {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: theme.spacing.xs) {
                Text(selectedValue)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textPrimary)

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(minWidth: 140)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? theme.colors.surfaceSecondary : theme.colors.surfacePrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(theme.colors.borderSubtle, lineWidth: 1)
            )
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
