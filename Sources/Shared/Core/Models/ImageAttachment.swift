import Foundation

public struct ImageAttachment: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public var itemId: UUID
    public var fileName: String
    public var relativePath: String
    public var isPrimary: Bool
    public var createdAt: Date

    public init(
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
