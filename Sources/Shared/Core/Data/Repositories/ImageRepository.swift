import Foundation
import GRDB

protocol ImageRepositoryProtocol {
    func fetchImages(forItemId id: UUID) async throws -> [ImageAttachment]
    func addImage(_ image: ImageAttachment) async throws
    func deleteImage(id: UUID) async throws
}

class ImageRepository: ImageRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    func fetchImages(forItemId id: UUID) async throws -> [ImageAttachment] {
        try await dbManager.reader.read { db in
            try ImageAttachment.filter(Column(SchemaDefinitions.ImageAttachmentTable.itemId) == id)
                .fetchAll(db)
        }
    }

    func addImage(_ image: ImageAttachment) async throws {
        try await dbManager.dbWriter.write { db in
            try image.insert(db)
        }
    }

    func deleteImage(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try ImageAttachment.deleteOne(db, key: id)
        }
    }
}
