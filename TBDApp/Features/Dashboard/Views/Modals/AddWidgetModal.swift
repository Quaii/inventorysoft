import SwiftUI

/// Add Widget Modal - Custom UI for adding new dashboard widgets
struct AddWidgetModal: View {
    @Environment(\.theme) var theme
    @Binding var isPresented: Bool
    let onAddWidget: (DashboardWidgetType, DashboardWidgetSize, String) -> Void

    @State private var selectedType: DashboardWidgetType?
    @State private var selectedSize: DashboardWidgetSize = .medium
    @State private var widgetName: String = ""
    @State private var searchQuery: String = ""

    var filteredWidgetTypes: [DashboardWidgetType] {
        if searchQuery.isEmpty {
            return DashboardWidgetType.allCases
        }
        return DashboardWidgetType.allCases.filter { type in
            type.displayName.localizedCaseInsensitiveContains(searchQuery)
                || type.description.localizedCaseInsensitiveContains(searchQuery)
        }
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
                    Text("Add Widget")
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
                HStack(alignment: .top, spacing: 0) {
                    // Left: Widget Gallery
                    VStack(alignment: .leading, spacing: theme.spacing.m) {
                        // Search
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(theme.colors.textSecondary)
                            TextField("Search widgets...", text: $searchQuery)
                                .textFieldStyle(.plain)
                        }
                        .padding(theme.spacing.m)
                        .background(theme.colors.backgroundSecondary)
                        .cornerRadius(theme.radii.small)

                        // Widget List
                        ScrollView {
                            VStack(spacing: theme.spacing.s) {
                                ForEach(filteredWidgetTypes, id: \.self) { type in
                                    WidgetTypeRow(
                                        type: type,
                                        isSelected: selectedType == type,
                                        onSelect: {
                                            selectedType = type
                                            selectedSize = type.defaultSize
                                            if widgetName.isEmpty {
                                                widgetName = type.displayName
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .frame(width: 300)
                    .padding(theme.spacing.xl)

                    Divider()

                    // Right: Configuration
                    VStack(alignment: .leading, spacing: theme.spacing.xl) {
                        if let type = selectedType {
                            // Preview
                            VStack(alignment: .leading, spacing: theme.spacing.m) {
                                Text("Preview")
                                    .font(theme.typography.sectionTitle)
                                    .foregroundColor(theme.colors.textPrimary)

                                WidgetPreview(type: type, size: selectedSize)
                            }

                            // Configuration
                            VStack(alignment: .leading, spacing: theme.spacing.m) {
                                Text("Configuration")
                                    .font(theme.typography.sectionTitle)
                                    .foregroundColor(theme.colors.textPrimary)

                                // Widget Name
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    Text("Widget Name")
                                        .font(theme.typography.caption)
                                        .foregroundColor(theme.colors.textSecondary)

                                    TextField("Enter name", text: $widgetName)
                                        .textFieldStyle(.plain)
                                        .padding(theme.spacing.m)
                                        .background(theme.colors.backgroundSecondary)
                                        .cornerRadius(theme.radii.small)
                                }

                                // Size Picker
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    Text("Size")
                                        .font(theme.typography.caption)
                                        .foregroundColor(theme.colors.textSecondary)

                                    HStack(spacing: theme.spacing.s) {
                                        ForEach(
                                            [DashboardWidgetSize.small, .medium, .large], id: \.self
                                        ) { size in
                                            SizeOptionButton(
                                                size: size,
                                                isSelected: selectedSize == size,
                                                onSelect: { selectedSize = size }
                                            )
                                        }
                                    }
                                }
                            }

                            Spacer()

                            // Actions
                            HStack(spacing: theme.spacing.m) {
                                Button("Cancel") {
                                    isPresented = false
                                }
                                .buttonStyle(SecondaryButtonStyle())

                                Button("Add Widget") {
                                    onAddWidget(type, selectedSize, widgetName)
                                    isPresented = false
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .disabled(widgetName.isEmpty)
                            }
                        } else {
                            // Empty State
                            VStack(spacing: theme.spacing.m) {
                                Image(systemName: "square.grid.3x3.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(theme.colors.textSecondary.opacity(0.3))

                                Text("Select a widget type")
                                    .font(theme.typography.body)
                                    .foregroundColor(theme.colors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(width: 400)
                    .padding(theme.spacing.xl)
                }
                .frame(height: 500)
            }
            .frame(width: 700)
            .background(theme.colors.backgroundPrimary)
            .cornerRadius(theme.radii.large)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Supporting Views

struct WidgetTypeRow: View {
    @Environment(\.theme) var theme
    let type: DashboardWidgetType
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: theme.spacing.m) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(
                        isSelected ? theme.colors.accentPrimary : theme.colors.textSecondary
                    )
                    .frame(width: 32, height: 32)
                    .background(isSelected ? theme.colors.accentPrimary.opacity(0.1) : Color.clear)
                    .cornerRadius(theme.radii.small)

                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textPrimary)

                    Text(type.description)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.colors.accentPrimary)
                }
            }
            .padding(theme.spacing.m)
            .background(isSelected ? theme.colors.accentPrimary.opacity(0.05) : Color.clear)
            .cornerRadius(theme.radii.small)
        }
        .buttonStyle(.plain)
    }
}

struct WidgetPreview: View {
    @Environment(\.theme) var theme
    let type: DashboardWidgetType
    let size: DashboardWidgetSize

    var body: some View {
        VStack(spacing: theme.spacing.m) {
            Image(systemName: type.icon)
                .font(.system(size: 32))
                .foregroundColor(theme.colors.accentPrimary)

            Text(type.displayName)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textPrimary)

            Text("Size: \(size.displayName)")
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(theme.colors.backgroundSecondary)
        .cornerRadius(theme.radii.medium)
    }
}

struct SizeOptionButton: View {
    @Environment(\.theme) var theme
    let size: DashboardWidgetSize
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Text(size.displayName)
                .font(theme.typography.body)
                .foregroundColor(isSelected ? .white : theme.colors.textPrimary)
                .padding(.vertical, theme.spacing.s)
                .padding(.horizontal, theme.spacing.m)
                .background(
                    isSelected ? theme.colors.accentPrimary : theme.colors.backgroundSecondary
                )
                .cornerRadius(theme.radii.small)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.theme) var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, theme.spacing.m)
            .padding(.horizontal, theme.spacing.l)
            .background(theme.colors.accentPrimary)
            .foregroundColor(.white)
            .cornerRadius(theme.radii.small)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
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
