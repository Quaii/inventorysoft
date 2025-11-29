import SwiftUI

#if os(macOS)
    import AppKit
    public typealias PlatformImage = NSImage
#else
    import UIKit
    public typealias PlatformImage = UIImage
#endif

protocol ImageServiceProtocol {
    func saveImage(_ data: Data, for itemId: UUID) async throws -> ImageAttachment
    func loadImage(attachment: ImageAttachment) async throws -> PlatformImage?
    func deleteImage(attachment: ImageAttachment) async throws
}

class ImageService: ImageServiceProtocol {
    private let fileManager = FileManager.default
    private let imagesDirectoryName = "Images"

    private var imagesDirectoryURL: URL {
        let appSupportURL = try! fileManager.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil,
            create: true)
        let directoryURL = appSupportURL.appendingPathComponent(
            imagesDirectoryName, isDirectory: true)
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        return directoryURL
    }

    func saveImage(_ data: Data, for itemId: UUID) async throws -> ImageAttachment {
        let imageId = UUID()
        let fileName = "\(imageId.uuidString).jpg"
        let itemDirectoryURL = imagesDirectoryURL.appendingPathComponent(
            itemId.uuidString, isDirectory: true)

        if !fileManager.fileExists(atPath: itemDirectoryURL.path) {
            try fileManager.createDirectory(at: itemDirectoryURL, withIntermediateDirectories: true)
        }

        let fileURL = itemDirectoryURL.appendingPathComponent(fileName)
        try data.write(to: fileURL)

        return ImageAttachment(
            id: imageId,
            itemId: itemId,
            fileName: fileName,
            relativePath: "\(itemId.uuidString)/\(fileName)",
            createdAt: Date()
        )
    }

    func loadImage(attachment: ImageAttachment) async throws -> PlatformImage? {
        let fileURL = imagesDirectoryURL.appendingPathComponent(attachment.relativePath)
        let data = try Data(contentsOf: fileURL)
        return PlatformImage(data: data)
    }

    func deleteImage(attachment: ImageAttachment) async throws {
        let fileURL = imagesDirectoryURL.appendingPathComponent(attachment.relativePath)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
