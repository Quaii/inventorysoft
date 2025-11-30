import SwiftUI
import UniformTypeIdentifiers

struct ImportMappingView: View {
    let importURL: URL
    let targetType: ImportTargetType
    @StateObject private var viewModel: ImportMappingViewModel
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss

    init(
        importURL: URL, targetType: ImportTargetType,
        importMappingService: ImportMappingServiceProtocol,
        importProfileRepository: ImportProfileRepositoryProtocol
    ) {
        self.importURL = importURL
        self.targetType = targetType
        _viewModel = StateObject(
            wrappedValue: ImportMappingViewModel(
                importURL: importURL,
                targetType: targetType,
                importMappingService: importMappingService,
                importProfileRepository: importProfileRepository
            ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(theme.colors.error)
                } else {
                    // Profile selector
                    HStack {
                        Menu {
                            ForEach(viewModel.savedProfiles) { profile in
                                Button(profile.name) {
                                    viewModel.loadProfile(profile)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc.text")
                                Text(viewModel.selectedProfile?.name ?? "Select Profile")
                            }
                        }

                        Spacer()

                        Button("Save as Profile") {
                            viewModel.showingSaveProfile = true
                        }
                    }
                    .padding(theme.spacing.l)

                    Divider()

                    // Mapping list
                    List {
                        ForEach(Array(viewModel.sourceFields.enumerated()), id: \.offset) {
                            index, sourceField in
                            HStack {
                                // Source field
                                VStack(alignment: .leading) {
                                    Text(sourceField)
                                        .font(theme.typography.body)
                                    if index < viewModel.sampleData.count,
                                        !viewModel.sampleData[index].isEmpty
                                    {
                                        Text(viewModel.sampleData[index])
                                            .font(theme.typography.caption)
                                            .foregroundColor(theme.colors.textSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "arrow.right")
                                    .foregroundColor(theme.colors.textSecondary)

                                // Target field
                                Picker(
                                    "",
                                    selection: Binding(
                                        get: { viewModel.fieldMappings[sourceField] ?? "" },
                                        set: { newValue in
                                            viewModel.fieldMappings[sourceField] =
                                                newValue.isEmpty ? nil : newValue
                                        }
                                    )
                                ) {
                                    Text("Skip").tag("")
                                    ForEach(viewModel.availableTargetFields, id: \.self) {
                                        targetField in
                                        Text(targetField).tag(targetField)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Map Fields")
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
                    Button("Import") {
                        Task {
                            await viewModel.performImport()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canImport)
                }
            }
            .sheet(isPresented: $viewModel.showingSaveProfile) {
                SaveProfileSheet(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.parseFile()
        }
    }
}

struct SaveProfileSheet: View {
    @ObservedObject var viewModel: ImportMappingViewModel
    @Environment(\.dismiss) var dismiss
    @State private var profileName = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Profile Name", text: $profileName)
            }
            .navigationTitle("Save Import Profile")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveProfile(name: profileName)
                            dismiss()
                        }
                    }
                    .disabled(profileName.isEmpty)
                }
            }
        }
    }
}

@MainActor
class ImportMappingViewModel: ObservableObject {
    private let importURL: URL
    private let targetType: ImportTargetType
    private let importMappingService: ImportMappingServiceProtocol
    private let importProfileRepository: ImportProfileRepositoryProtocol

    @Published var sourceFields: [String] = []
    @Published var sampleData: [String] = []
    @Published var fieldMappings: [String: String] = [:]
    @Published var availableTargetFields: [String] = []
    @Published var savedProfiles: [ImportProfile] = []
    @Published var selectedProfile: ImportProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingSaveProfile = false

    var canImport: Bool {
        !fieldMappings.values.compactMap { $0 }.isEmpty
    }

    init(
        importURL: URL, targetType: ImportTargetType,
        importMappingService: ImportMappingServiceProtocol,
        importProfileRepository: ImportProfileRepositoryProtocol
    ) {
        self.importURL = importURL
        self.targetType = targetType
        self.importMappingService = importMappingService
        self.importProfileRepository = importProfileRepository

        // Set available target fields based on type
        switch targetType {
        case .item:
            availableTargetFields = [
                "title", "sku", "purchasePrice", "quantity", "category", "brand", "condition",
                "status",
            ]
        case .sale:
            availableTargetFields = ["platform", "soldPrice", "fees", "buyer", "dateSold"]
        case .purchase:
            availableTargetFields = ["batchName", "supplier", "cost", "datePurchased"]
        }
    }

    func parseFile() async {
        isLoading = true
        do {
            let (headers, rows) = try await importMappingService.parseCSV(fileURL: importURL)
            sourceFields = headers

            // Get sample data from first row
            if let firstRow = rows.first, firstRow.count == headers.count {
                sampleData = firstRow
            }

            // Auto-suggest mappings
            for (_, header) in headers.enumerated() {
                if let suggestion = importMappingService.suggestMapping(
                    sourceField: header, targetType: targetType)
                {
                    fieldMappings[header] = suggestion
                }
            }

            // Load saved profiles
            savedProfiles = try await importProfileRepository.getProfiles(for: targetType)

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadProfile(_ profile: ImportProfile) {
        selectedProfile = profile
        fieldMappings = Dictionary(
            uniqueKeysWithValues: profile.mappings.map { ($0.sourceField, $0.targetField) })
    }

    func saveProfile(name: String) async {
        let mappings: [FieldMapping] = fieldMappings.compactMap { key, value in
            if !value.isEmpty {
                return FieldMapping(sourceField: key, targetField: value)
            }
            return nil
        }

        let profile = ImportProfile(
            name: name,
            targetType: targetType,
            mappings: mappings
        )

        do {
            try await importProfileRepository.saveProfile(profile)
            savedProfiles = try await importProfileRepository.getProfiles(for: targetType)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func performImport() async {
        // In real implementation, this would parse the file and create entities
        // For now, this is a placeholder
        print("Importing with mappings: \(fieldMappings)")
    }
}
