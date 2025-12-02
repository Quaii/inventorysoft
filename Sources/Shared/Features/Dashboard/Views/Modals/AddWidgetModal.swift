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
        NavigationStack {
            HStack(spacing: 0) {
                // Left Sidebar: Widget Gallery
                List(selection: $selectedType) {
                    Section {
                        TextField("Search widgets...", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                    }

                    ForEach(WidgetCategory.allCases, id: \.self) { category in
                        let categoryWidgets = filteredWidgetTypes.filter { $0.category == category }
                        if !categoryWidgets.isEmpty {
                            Section(category.displayName) {
                                ForEach(categoryWidgets, id: \.self) { type in
                                    HStack {
                                        Label(type.displayName, systemImage: type.icon)
                                        Spacer()
                                        if selectedType == type {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    .tag(type)
                                }
                            }
                        }
                    }
                }
                .frame(width: 300)

                // Right Content: Configuration
                if let type = selectedType {
                    Form {
                        Section("Preview") {
                            VStack(alignment: .center, spacing: 16) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 48))
                                    .foregroundStyle(.blue)
                                Text(type.displayName)
                                    .font(.headline)
                                Text("Size: \(selectedSize.displayName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }

                        Section("Configuration") {
                            TextField("Widget Name", text: $widgetName)

                            Picker("Size", selection: $selectedSize) {
                                ForEach([DashboardWidgetSize.small, .medium, .large], id: \.self) {
                                    size in
                                    Text(size.displayName).tag(size)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                } else {
                    ContentUnavailableView("Select a Widget", systemImage: "square.grid.3x3.fill")
                }
            }
            .navigationTitle("Add Widget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let type = selectedType {
                            onAddWidget(type, selectedSize, widgetName)
                            isPresented = false
                        }
                    }
                    .disabled(selectedType == nil || widgetName.isEmpty)
                }
            }
            .onChange(of: selectedType) { _, newType in
                if let type = newType {
                    selectedSize = type.defaultSize
                    if widgetName.isEmpty {
                        widgetName = type.displayName
                    }
                }
            }
        }
        .frame(width: 800, height: 600)
    }
}
