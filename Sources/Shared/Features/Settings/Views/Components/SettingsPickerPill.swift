import SwiftUI

/// Custom dropdown menu that matches app card styling
struct CustomDropdownMenu: View {
    let options: [String]
    let selectedValue: String
    let onSelect: (String) -> Void
    @Binding var isPresented: Bool

    @Environment(\.theme) var theme
    @State private var hoveredOption: String?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    onSelect(option)
                    isPresented = false
                }) {
                    HStack {
                        Text(option)
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.textPrimary)

                        Spacer()

                        if option == selectedValue {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(theme.colors.accentSecondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        hoveredOption == option ? theme.colors.highlight : theme.colors.backgroundPrimary
                    )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .onHover { hovering in
                    hoveredOption = hovering ? option : nil
                }

                if option != options.last {
                    Divider()
                        .background(theme.colors.borderSubtle)
                }
            }
        }
        .background(theme.colors.surfaceElevated)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(4)
        .frame(minWidth: 160)
    }
}

/// Refined picker pill that shows custom dropdown instead of Menu
struct SettingsPickerPill: View {
    let selectedValue: String
    let options: [String]
    let onSelect: (String) -> Void

    @Environment(\.theme) var theme
    @State private var isHovered = false
    @State private var showDropdown = false

    var body: some View {
        Button(action: {
            showDropdown.toggle()
        }) {
            HStack(spacing: theme.spacing.xs) {
                Text(selectedValue)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textPrimary)

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
                    .rotationEffect(.degrees(showDropdown ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: showDropdown)
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
                    .stroke(
                        showDropdown
                            ? theme.colors.accentSecondary.opacity(0.5) : theme.colors.borderSubtle,
                        lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .popover(isPresented: $showDropdown, arrowEdge: .bottom) {
            CustomDropdownMenu(
                options: options,
                selectedValue: selectedValue,
                onSelect: onSelect,
                isPresented: $showDropdown
            )
        }
    }
}
