import Foundation

public struct Category: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String

    public var colorHex: String?

    public init(id: UUID = UUID(), name: String, colorHex: String? = nil) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}
