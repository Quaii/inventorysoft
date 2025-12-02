import SwiftUI

/// Edit Widget Modal - Configure existing dashboard widgets
struct EditWidgetModal: View {
    @Binding var isPresented: Bool
    @Binding var widget: UserWidget
    let onSave: (UserWidget) -> Void

    @State private var widgetName: String
    @State private var selectedSize: DashboardWidgetSize
    @State private var hasChanges = false

    init(
        isPresented: Binding<Bool>, widget: Binding<UserWidget>,
        onSave: @escaping (UserWidget) -> Void
    ) {
        self._isPresented = isPresented
        self._widget = widget
        self.onSave = onSave
        self._widgetName = State(initialValue: widget.wrappedValue.name)
        self._selectedSize = State(initialValue: widget.wrappedValue.size)
    }

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Modal Content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Configure Widget")
                        .font(.largeTitle)
                        .foregroundColor(.primary)

                    Spacer()

                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)

                Divider()

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Widget Type Display
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Widget Type")
                                .font(.headline)
                                .foregroundColor(.primary)

                            HStack(spacing: 12) {
                                Image(systemName: widget.type.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                                    .frame(width: 48, height: 48)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(widget.type.displayName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)

                                    Text(widget.type.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding(12)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                        }

                        // Widget Name
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Widget Name")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextField("Enter widget name", text: $widgetName)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(4)
                                .onChange(of: widgetName) { _, _ in
                                    hasChanges = true
                                }
                        }

                        // Size Picker
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Widget Size")
                                .font(.headline)
                                .foregroundColor(.primary)

                            HStack(spacing: 8) {
                                ForEach([DashboardWidgetSize.small, .medium, .large], id: \.self) {
                                    size in
                                    WidgetSizeButton(
                                        size: size,
                                        isSelected: selectedSize == size,
                                        onSelect: {
                                            selectedSize = size
                                            hasChanges = true
                                        }
                                    )
                                }
                            }
                        }

                        // Configuration Preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preview")
                                .font(.headline)
                                .foregroundColor(.primary)

                            ConfigurationPreview(
                                type: widget.type,
                                name: widgetName,
                                size: selectedSize
                            )
                        }
                    }
                    .padding(24)
                }

                Divider()

                // Actions
                HStack(spacing: 12) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .buttonStyle(ConfigSecondaryButtonStyle())

                    Button("Save Changes") {
                        var updatedWidget = widget
                        updatedWidget.name = widgetName
                        updatedWidget.size = selectedSize
                        onSave(updatedWidget)
                        isPresented = false
                    }
                    .buttonStyle(ConfigPrimaryButtonStyle())
                    .disabled(!hasChanges || widgetName.isEmpty)
                }
                .padding(24)
            }
            .frame(width: 500)
            .background(Color(nsColor: .windowBackgroundColor))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Supporting Views

struct WidgetSizeButton: View {
    let size: DashboardWidgetSize
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                // Size Icon
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        isSelected ? Color.blue : Color.secondary.opacity(0.1)
                    )
                    .frame(width: sizeWidth, height: 40)

                Text(size.displayName)
                    .font(.caption)
                    .foregroundColor(
                        isSelected ? .blue : .secondary)
            }
            .padding(12)
            .background(
                isSelected ? Color.blue.opacity(0.1) : Color(nsColor: .windowBackgroundColor)
            )
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        isSelected ? Color.blue : Color(nsColor: .windowBackgroundColor),
                        lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var sizeWidth: CGFloat {
        switch size {
        case .small: return 40
        case .medium: return 60
        case .large: return 80
        }
    }
}

struct ConfigurationPreview: View {
    let type: DashboardWidgetType
    let name: String
    let size: DashboardWidgetSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: type.icon)
                    .font(.system(size: 14))
                    .foregroundColor(.blue)

                Text(name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Spacer()

                Text(size.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)

            Divider()

            // Preview Content
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.blue.opacity(0.3))

                Text("Widget Preview")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
        }
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Button Styles

struct ConfigPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isEnabled ? Color.blue : Color.secondary.opacity(0.1))
            .foregroundColor(isEnabled ? .white : .secondary)
            .cornerRadius(4)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct ConfigSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.secondary.opacity(0.1))
            .foregroundColor(.primary)
            .cornerRadius(4)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
