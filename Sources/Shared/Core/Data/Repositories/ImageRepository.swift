import Foundation
import GRDB

public protocol ImageRepositoryProtocol {
    func fetchImages(forItemId id: UUID) async throws -> [ImageAttachment]
    func addImage(_ image: ImageAttachment) async throws
    func deleteImage(id: UUID) async throws
}

public class ImageRepository: ImageRepositoryProtocol {
    private let dbManager = DatabaseManager.shared

    public init() {}

    public func fetchImages(forItemId id: UUID) async throws -> [ImageAttachment] {
        try await dbManager.reader.read { db in
            try ImageAttachment.filter(Column(SchemaDefinitions.ImageAttachmentTable.itemId) == id)
                .fetchAll(db)
        }
    }

    public func addImage(_ image: ImageAttachment) async throws {
        try await dbManager.dbWriter.write { db in
            try image.insert(db)
        }
    }

    public func deleteImage(id: UUID) async throws {
        try await dbManager.dbWriter.write { db in
            _ = try ImageAttachment.deleteOne(db, key: id)
        }
    }
}
