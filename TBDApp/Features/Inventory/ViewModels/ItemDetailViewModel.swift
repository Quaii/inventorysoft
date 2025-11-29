import Combine
import Foundation

class ItemDetailViewModel: ObservableObject {
    @Published var item: Item?
    @Published var images: [ImageAttachment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

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
        } catch {
            self.errorMessage = "Failed to load item details: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    func saveItem(_ item: Item) async {
        do {
            if (try await itemRepository.fetchItem(id: item.id)) != nil {
                try await itemRepository.updateItem(item)
            } else {
                try await itemRepository.createItem(item)
            }
            self.item = item  // Update local state
        } catch {
            self.errorMessage = "Failed to save item: \(error.localizedDescription)"
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
