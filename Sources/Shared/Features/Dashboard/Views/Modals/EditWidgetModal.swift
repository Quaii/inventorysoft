import SwiftUI

/// Edit Widget Modal - Configure existing dashboard widgets
struct EditWidgetModal: View {
    @Environment(\.theme) var theme
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
                        .font(theme.typography.pageTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(theme.colors.backgroundSecondary)
                            .cornerRadius(theme.radii.small)
                    }
                    .buttonStyle(.plain)
                }
                .padding(theme.spacing.xl)

                Divider()

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: theme.spacing.xl) {
                        // Widget Type Display
                        VStack(alignment: .leading, spacing: theme.spacing.m) {
                            Text("Widget Type")
                                .font(theme.typography.sectionTitle)
                                .foregroundColor(theme.colors.textPrimary)

                            HStack(spacing: theme.spacing.m) {
                                Image(systemName: widget.type.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(theme.colors.accentPrimary)
                                    .frame(width: 48, height: 48)
                                    .background(theme.colors.accentPrimary.opacity(0.1))
                                    .cornerRadius(theme.radii.medium)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(widget.type.displayName)
                                        .font(theme.typography.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(theme.colors.textPrimary)

                                    Text(widget.type.description)
                                        .font(theme.typography.caption)
                                        .foregroundColor(theme.colors.textSecondary)
                                }

                                Spacer()
                            }
                            .padding(theme.spacing.m)
                            .background(theme.colors.backgroundSecondary)
                            .cornerRadius(theme.radii.medium)
                        }

                        // Widget Name
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            Text("Widget Name")
                                .font(theme.typography.sectionTitle)
                                .foregroundColor(theme.colors.textPrimary)

                            TextField("Enter widget name", text: $widgetName)
                                .textFieldStyle(.plain)
                                .padding(theme.spacing.m)
                                .background(theme.colors.backgroundSecondary)
                                .cornerRadius(theme.radii.small)
                                .onChange(of: widgetName) { _, _ in
                                    hasChanges = true
                                }
                        }

                        // Size Picker
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            Text("Widget Size")
                                .font(theme.typography.sectionTitle)
                                .foregroundColor(theme.colors.textPrimary)

                            HStack(spacing: theme.spacing.s) {
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
                        VStack(alignment: .leading, spacing: theme.spacing.m) {
                            Text("Preview")
                                .font(theme.typography.sectionTitle)
                                .foregroundColor(theme.colors.textPrimary)

                            ConfigurationPreview(
                                type: widget.type,
                                name: widgetName,
                                size: selectedSize
                            )
                        }
                    }
                    .padding(theme.spacing.xl)
                }

                Divider()

                // Actions
                HStack(spacing: theme.spacing.m) {
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
                .padding(theme.spacing.xl)
            }
            .frame(width: 500)
            .background(theme.colors.backgroundPrimary)
            .cornerRadius(theme.radii.large)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Supporting Views

struct WidgetSizeButton: View {
    @Environment(\.theme) var theme
    let size: DashboardWidgetSize
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: theme.spacing.xs) {
                // Size Icon
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        isSelected ? theme.colors.accentPrimary : theme.colors.backgroundSecondary
                    )
                    .frame(width: sizeWidth, height: 40)

                Text(size.displayName)
                    .font(theme.typography.caption)
                    .foregroundColor(
                        isSelected ? theme.colors.accentPrimary : theme.colors.textSecondary)
            }
            .padding(theme.spacing.m)
            .background(isSelected ? theme.colors.accentPrimary.opacity(0.1) : theme.colors.backgroundPrimary)
            .cornerRadius(theme.radii.small)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.small)
                    .stroke(isSelected ? theme.colors.accentPrimary : theme.colors.backgroundPrimary, lineWidth: 2)
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
    @Environment(\.theme) var theme
    let type: DashboardWidgetType
    let name: String
    let size: DashboardWidgetSize

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.m) {
            // Header
            HStack {
                Image(systemName: type.icon)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.accentSecondary)

                Text(name)
                    .font(theme.typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                Text(size.displayName)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(theme.spacing.m)

            Divider()

            // Preview Content
            VStack(spacing: theme.spacing.m) {
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(theme.colors.accentPrimary.opacity(0.3))

                Text("Widget Preview")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
        }
        .background(theme.colors.backgroundSecondary)
        .cornerRadius(theme.radii.medium)
    }
}

// MARK: - Button Styles

struct ConfigPrimaryButtonStyle: ButtonStyle {
    @Environment(\.theme) var theme
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, theme.spacing.m)
            .padding(.horizontal, theme.spacing.l)
            .background(isEnabled ? theme.colors.accentPrimary : theme.colors.backgroundSecondary)
            .foregroundColor(isEnabled ? .white : theme.colors.textSecondary)
            .cornerRadius(theme.radii.small)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct ConfigSecondaryButtonStyle: ButtonStyle {
    @Environment(\.theme) var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, theme.spacing.m)
            .padding(.horizontal, theme.spacing.l)
            .background(theme.colors.backgroundSecondary)
            .foregroundColor(theme.colors.textPrimary)
            .cornerRadius(theme.radii.small)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
