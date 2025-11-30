import SwiftUI

struct ChartColorConfigView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    @Binding var colorPalette: String

    @State private var selectedPalette: String

    init(colorPalette: Binding<String>) {
        self._colorPalette = colorPalette
        self._selectedPalette = State(initialValue: colorPalette.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Chart Colors")
                        .font(theme.typography.headingL)
                        .foregroundColor(theme.colors.textPrimary)

                    Text("Choose a color scheme for this chart")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(theme.spacing.l)
            .background(theme.colors.backgroundPrimary)

            Divider().overlay(theme.colors.divider)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.m) {
                    ForEach(Array(ChartColorPalette.palettes.keys.sorted()), id: \.self) {
                        paletteName in
                        ColorPaletteRow(
                            paletteName: paletteName,
                            colors: ChartColorPalette.colors(for: paletteName),
                            isSelected: selectedPalette == paletteName,
                            onSelect: { selectedPalette = paletteName }
                        )
                    }
                }
                .padding(theme.spacing.l)
            }

            // Footer
            Divider().overlay(theme.colors.divider)

            HStack {
                AppButton(title: "Cancel", style: .ghost) {
                    dismiss()
                }

                Spacer()

                AppButton(title: "Apply Colors", style: .primary) {
                    colorPalette = selectedPalette
                    dismiss()
                }
            }
            .padding(theme.spacing.l)
            .background(theme.colors.backgroundPrimary)
        }
        .frame(width: 500, height: 600)
        .background(theme.colors.backgroundPrimary)
    }
}

struct ColorPaletteRow: View {
    let paletteName: String
    let colors: [String]
    let isSelected: Bool
    let onSelect: () -> Void

    @Environment(\.theme) var theme

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: theme.spacing.m) {
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(
                        isSelected ? theme.colors.accentPrimary : theme.colors.textMuted)

                // Palette Name
                Text(paletteName.capitalized)
                    .font(theme.typography.cardTitle)
                    .foregroundColor(theme.colors.textPrimary)
                    .frame(width: 100, alignment: .leading)

                // Color Swatches
                HStack(spacing: 4) {
                    ForEach(colors.prefix(5), id: \.self) { colorHex in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: colorHex))
                            .frame(width: 40, height: 40)
                    }
                }

                Spacer()
            }
            .padding(theme.spacing.m)
            .background(
                isSelected ? theme.colors.surfaceElevated : theme.colors.surfacePrimary
            )
            .cornerRadius(theme.radii.card)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.card)
                    .strokeBorder(
                        isSelected ? theme.colors.borderHighlight : theme.colors.borderSubtle,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
