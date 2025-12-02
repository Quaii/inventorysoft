import SwiftUI

/// SettingsPicker - Custom picker to match specs
struct SettingsPicker: View {
    let selection: Binding<String>
    let options: [String]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection.wrappedValue = option
                }) {
                    Text(option)
                    if selection.wrappedValue == option {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(selection.wrappedValue)
                    .font(.body)  // "value_font": "body"
                    .foregroundColor(.primary)

                Image(systemName: "chevron.down")  // "chevron_icon": "SF Symbol: chevron.down"
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))  // "background": "theme.surface.quaternary" -> surfaceElevated (surface3)
            .cornerRadius(8)  // "corner_radius": "theme.radii.lg"
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}

/// SettingsToggle - Custom toggle to match specs
struct SettingsToggle: View {
    let isOn: Binding<Bool>

    var body: some View {
        Toggle("", isOn: isOn)
            .toggleStyle(.switch)  // "switch_style": "modern_iOS_style"
            .tint(.blue)  // "thumb_style": "accent_color"
            .labelsHidden()
    }
}
