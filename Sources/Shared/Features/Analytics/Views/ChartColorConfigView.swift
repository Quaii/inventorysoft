import SwiftUI

struct ChartColorConfigView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var colorPalette: String

    @State private var selectedPalette: String

    init(colorPalette: Binding<String>) {
        self._colorPalette = colorPalette
        self._selectedPalette = State(initialValue: colorPalette.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(ChartColorPalette.palettes.keys.sorted()), id: \.self) {
                        paletteName in
                        paletteRow(for: paletteName)
                    }
                } header: {
                    Text("Choose a color scheme for this chart")
                }
            }
            .navigationTitle("Chart Colors")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply Colors") {
                        colorPalette = selectedPalette
                        dismiss()
                    }
                }
            }
        }
    }

    private func paletteRow(for paletteName: String) -> some View {
        Button(action: { selectedPalette = paletteName }) {
            HStack {
                // Selection Indicator
                Image(
                    systemName: selectedPalette == paletteName ? "checkmark.circle.fill" : "circle"
                )
                .foregroundStyle(selectedPalette == paletteName ? .blue : .secondary)

                // Palette Name
                Text(paletteName.capitalized)
                    .foregroundStyle(.primary)
                    .frame(width: 100, alignment: .leading)

                // Color Swatches
                HStack(spacing: 4) {
                    ForEach(ChartColorPalette.colors(for: paletteName).prefix(5), id: \.self) {
                        colorHex in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: colorHex))
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
