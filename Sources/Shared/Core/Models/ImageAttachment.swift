import Foundation

struct ImageAttachment: Identifiable, Codable, Equatable {
    let id: UUID
    var itemId: UUID
    var fileName: String
    var relativePath: String
    var isPrimary: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        itemId: UUID,
        fileName: String,
        relativePath: String,
        isPrimary: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemId = itemId
        self.fileName = fileName
        self.relativePath = relativePath
        self.isPrimary = isPrimary
        self.createdAt = createdAt
    }
}
