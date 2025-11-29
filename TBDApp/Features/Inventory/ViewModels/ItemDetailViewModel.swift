#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

class ItemDetailViewModel: ObservableObject {
    @Published var item: Item?
    @Published var images: [ImageAttachment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Form fields
    @Published var name: String = ""
    @Published var brand: String = ""
    @Published var selectedCategory: String = "Other"
    @Published var purchasePrice: Double = 0.0
    @Published var sellingPrice: Double = 0.0
    @Published var quantity: Int = 0
    @Published var status: ItemStatus = .draft
    @Published var note: String = ""
    @Published var selectedImage: PlatformImage?

    let categories = ["Electronics", "Clothing", "Home", "Sports", "Other"]

    var isNewItem: Bool {
        item == nil
    }

    private let itemRepository: ItemRepositoryProtocol
    private let imageRepository: ImageRepositoryProtocol
    private let imageService: ImageServiceProtocol

    init(
        itemRepository: ItemRepositoryProtocol, imageRepository: ImageRepositoryProtocol,
        imageService: ImageServiceProtocol
    ) {
        self.itemRepository = itemRepository
        self.imageRepository = imageRepository
        self.imageService = imageService
    }

    @MainActor
    func loadItem(id: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            self.item = try await itemRepository.fetchItem(id: id)
            self.images = try await imageRepository.fetchImages(forItemId: id)

            if let item = self.item {
                self.name = item.title
                self.brand = ""  // Item model doesn't have brand yet?
                self.selectedCategory = "Other"  // Item model doesn't have category yet?
                self.purchasePrice = NSDecimalNumber(decimal: item.purchasePrice).doubleValue
                self.sellingPrice = 0.0  // Item model doesn't have sellingPrice yet?
                self.quantity = item.quantity
                self.status = item.status
                self.note = ""  // Item model doesn't have note yet?
            }
        } catch {
            self.errorMessage = "Failed to load item details: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    func saveItem() async -> Bool {
        do {
            let newItem = Item(
                id: item?.id ?? UUID(),
                title: name,
                purchasePrice: Decimal(purchasePrice),
                quantity: quantity,
                status: status
            )
            // Note: Missing fields in Item model (brand, category, sellingPrice, note) are ignored for now

            if (try await itemRepository.fetchItem(id: newItem.id)) != nil {
                try await itemRepository.updateItem(newItem)
            } else {
                try await itemRepository.createItem(newItem)
            }
            self.item = newItem
            return true
        } catch {
            self.errorMessage = "Failed to save item: \(error.localizedDescription)"
            return false
        }
    }

    @MainActor
    func deleteImage(_ attachment: ImageAttachment) async {
        do {
            try await imageService.deleteImage(attachment: attachment)
            try await imageRepository.deleteImage(id: attachment.id)
            if let index = images.firstIndex(where: { $0.id == attachment.id }) {
                images.remove(at: index)
            }
        } catch {
            self.errorMessage = "Failed to delete image: \(error.localizedDescription)"
        }
    }

    @MainActor
    func addImage(data: Data, for itemId: UUID) async {
        do {
            let attachment = try await imageService.saveImage(data, for: itemId)
            try await imageRepository.addImage(attachment)
            images.append(attachment)
        } catch {
            self.errorMessage = "Failed to add image: \(error.localizedDescription)"
        }
    }
}
