import SwiftUI

struct ItemDetailView: View {
    let itemId: UUID?
    @StateObject var viewModel: ItemDetailViewModel
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab = 0  // 0: Details, 1: Analytics

    init(itemId: UUID? = nil, viewModel: ItemDetailViewModel) {
        self.itemId = itemId
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Form {
                        if !viewModel.isNewItem {
                            Picker("View", selection: $selectedTab) {
                                Text("Details").tag(0)
                                Text("Analytics").tag(1)
                            }
                            .pickerStyle(.segmented)
                            .padding(.bottom)
                        }

                        if selectedTab == 0 {
                            detailsView
                        } else {
                            analyticsView
                        }
                    }
                    .formStyle(.grouped)
                }
            }
            .navigationTitle(viewModel.isNewItem ? "Add Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if await viewModel.saveItem() {
                                dismiss()
                            }
                        }
                    }
                }
                if !viewModel.isNewItem {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete", role: .destructive) {
                            // Show delete confirmation
                        }
                    }
                }
            }
        }
        .task {
            if let id = itemId {
                await viewModel.loadItem(id: id)
            }
        }
    }

    // MARK: - Details View
    private var detailsView: some View {
        Group {
            // Basic Info
            Section(header: Text("Basic Information")) {
                TextField("Name", text: $viewModel.name)
                TextField("Brand", text: $viewModel.brand)
                Picker("Category", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            }

            // Image Gallery
            Section("Images") {
                if !viewModel.images.isEmpty {
                    TabView {
                        ForEach(viewModel.images) { attachment in
                            if let image = viewModel.loadedImages[attachment.id] {
                                #if os(iOS)
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                #elseif os(macOS)
                                    Image(nsImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                #endif
                            } else {
                                ProgressView()
                            }
                        }
                    }
                    .frame(height: 300)
                    #if os(iOS)
                        .tabViewStyle(.page)
                    #endif
                } else {
                    ContentUnavailableView(
                        "No Images",
                        systemImage: "photo.on.rectangle",
                        description: Text("Add images to showcase your item")
                    )
                    .frame(height: 200)
                }

                Button("Add Image") {
                    // Trigger image picker
                }
            }

            // Pricing
            Section("Pricing") {
                HStack {
                    Text("Purchase Price")
                    Spacer()
                    TextField(
                        "Purchase Price", value: $viewModel.purchasePrice,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    #if os(iOS)
                        #if os(iOS)
                            .keyboardType(.decimalPad)
                        #endif
                    #endif
                }

                HStack {
                    Text("Selling Price")
                    Spacer()
                    TextField(
                        "Selling Price", value: $viewModel.sellingPrice,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    #if os(iOS)
                        #if os(iOS)
                            .keyboardType(.decimalPad)
                        #endif
                    #endif
                }
            }

            // Inventory
            Section("Inventory") {
                HStack {
                    Text("Quantity")
                    Spacer()
                    TextField("Quantity", value: $viewModel.quantity, format: .number)
                        .multilineTextAlignment(.trailing)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                }

                Picker("Status", selection: $viewModel.status) {
                    ForEach(ItemStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
            }

            // Notes
            Section("Notes") {
                TextEditor(text: $viewModel.note)
                    .frame(height: 100)
            }
        }
    }

    // MARK: - Analytics View
    private var analyticsView: some View {
        Group {
            if let sale = viewModel.sale {
                Section("Performance") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        // Profit Card
                        GroupBox {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Net Profit", systemImage: "dollarsign.circle.fill")
                                    .foregroundStyle(.green)
                                Text(viewModel.profit?.formatted(.currency(code: "USD")) ?? "-")
                                    .font(.title)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        }

                        // Margin Card
                        GroupBox {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Margin", systemImage: "percent")
                                    .foregroundStyle(.blue)
                                Text(
                                    viewModel.margin?.formatted(
                                        .number.precision(.fractionLength(1)))
                                        ?? "-" + "%"
                                )
                                .font(.title)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        }

                        // Days to Sell Card
                        GroupBox {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Time to Sell", systemImage: "clock.fill")
                                    .foregroundStyle(.orange)
                                Text("\(viewModel.daysToSell ?? 0) Days")
                                    .font(.title)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        }
                    }
                }

                Section("Sale Details") {
                    LabeledContent(
                        "Sold Price", value: sale.soldPrice.formatted(.currency(code: "USD")))
                    LabeledContent("Fees", value: sale.fees.formatted(.currency(code: "USD")))
                    LabeledContent("Platform", value: sale.platform)
                    LabeledContent(
                        "Date Sold",
                        value: sale.dateSold.formatted(date: .abbreviated, time: .omitted))
                }
            } else {
                ContentUnavailableView {
                    Label("No Sales Data", systemImage: "chart.bar.xaxis")
                } description: {
                    Text("This item has not been sold yet.")
                }
                .frame(height: 300)
            }
        }
    }
}
