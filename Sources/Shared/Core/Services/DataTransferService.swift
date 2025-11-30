import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum DataTransferError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case fileAccessFailed
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "Failed to encode data."
        case .decodingFailed: return "Failed to decode data."
        case .fileAccessFailed: return "Failed to access file."
        case .invalidFormat: return "Invalid file format."
        }
    }
}

actor DataTransferService {
    static let shared = DataTransferService()

    // MARK: - JSON

    func exportToJSON<T: Encodable>(_ data: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        do {
            return try encoder.encode(data)
        } catch {
            throw DataTransferError.encodingFailed
        }
    }

    func importFromJSON<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw DataTransferError.decodingFailed
        }
    }

    // MARK: - CSV (Mock implementation for now)

    func exportToCSV<T>(_ data: [T]) throws -> String {
        // In a real app, we'd use reflection or a CSV library to generate CSV
        return "id,name,date\n1,Item 1,2023-01-01"
    }

    // MARK: - SQL (Mock implementation)

    func exportDatabase() throws -> URL {
        // Return path to current SQLite DB
        // For now, return a temp file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "inventory.sqlite")
        try "SQLite Header".write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }

    func importDatabase(from url: URL) throws {
        // Replace current DB with file at url
    }
}
