import SwiftUI

struct CustomFieldManagementView: View {
    @StateObject private var viewModel: CustomFieldManagementViewModel
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss
    @State private var showingAddField = false

    init(customFieldRepository: CustomFieldRepositoryProtocol) {
        _viewModel = StateObject(
            wrappedValue: CustomFieldManagementViewModel(repository: customFieldRepository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tabs for different entity types
                Picker("Entity Type", selection: $viewModel.selectedAppliesTo) {
                    ForEach(CustomFieldAppliesTo.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(theme.spacing.l)

                // Custom fields list
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.customFields.isEmpty {
                    AppEmptyStateView(
                        title: "No Custom Fields",
                        message: "Add custom fields to track additional information",
                        icon: "square.grid.3x3.square"
                    )
                } else {
                    List {
                        ForEach(viewModel.customFields) { field in
                            CustomFieldRow(field: field) {
                                Task {
                                    await viewModel.deleteField(field.id)
                                }
                            }
                        }
                        .onMove { indices, newOffset in
                            Task {
                                await viewModel.reorderFields(from: indices, to: newOffset)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Custom Fields")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddField = true }) {
                        Label("Add Field", systemImage: "plus")
                    }
                }
                #if os(iOS)
                    ToolbarItem(placement: .secondaryAction) {
                        EditButton()
                    }
                #endif
            }
            .sheet(isPresented: $showingAddField) {
                AddCustomFieldView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadFields()
        }
    }
}

struct CustomFieldRow: View {
    let field: CustomFieldDefinition
    let onDelete: () -> Void
    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: theme.spacing.m) {
            Image(systemName: field.type.icon)
                .foregroundColor(theme.colors.accentPrimary)
                .frame(width: 32, height: 32)
                .background(theme.colors.surfaceElevated)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(field.name)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textPrimary)
                Text(field.type.displayName + (field.isRequired ? " • Required" : ""))
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddCustomFieldView: View {
    @ObservedObject var viewModel: CustomFieldManagementViewModel
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var type: CustomFieldType = .text
    @State private var isRequired = false
    @State private var selectOptions = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Field Details") {
                    TextField("Field Name", text: $name)

                    Picker("Field Type", selection: $type) {
                        ForEach(CustomFieldType.allCases, id: \.self) { fieldType in
                            Label(fieldType.displayName, systemImage: fieldType.icon)
                                .tag(fieldType)
                        }
                    }

                    Toggle("Required Field", isOn: $isRequired)
                }

                if type == .select {
                    Section {
                        TextField("Options (comma separated)", text: $selectOptions)
                    } header: {
                        Text("Dropdown Options")
                    } footer: {
                        Text("Enter options separated by commas, e.g. 'Small, Medium, Large'")
                    }
                }
            }
            .navigationTitle("Add Custom Field")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await addField()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addField() async {
        let options =
            type == .select
            ? selectOptions.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            : nil

        await viewModel.addField(
            name: name,
            type: type,
            isRequired: isRequired,
            selectOptions: options
        )
        dismiss()
    }
}

@MainActor
class CustomFieldManagementViewModel: ObservableObject {
    private let repository: CustomFieldRepositoryProtocol

    @Published var selectedAppliesTo: CustomFieldAppliesTo = .item
    @Published var customFields: [CustomFieldDefinition] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(repository: CustomFieldRepositoryProtocol) {
        self.repository = repository
    }

    func loadFields() async {
        isLoading = true
        do {
            customFields = try await repository.getDefinitions(for: selectedAppliesTo)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func addField(name: String, type: CustomFieldType, isRequired: Bool, selectOptions: [String]?)
        async
    {
        do {
            let field = CustomFieldDefinition(
                name: name,
                type: type,
                appliesTo: selectedAppliesTo,
                selectOptions: selectOptions,
                isRequired: isRequired,
                sortOrder: customFields.count
            )
            try await repository.createDefinition(field)
            await loadFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteField(_ id: UUID) async {
        do {
            try await repository.deleteDefinition(id: id)
            await loadFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reorderFields(from source: IndexSet, to destination: Int) async {
        var updatedFields = customFields
        updatedFields.move(fromOffsets: source, toOffset: destination)

        // Update order for all fields
        for (index, field) in updatedFields.enumerated() {
            var updatedField = field
            updatedField.sortOrder = index
            do {
                try await repository.updateDefinition(updatedField)
            } catch {
                errorMessage = error.localizedDescription
                return
            }
        }

        await loadFields()
    }
}
