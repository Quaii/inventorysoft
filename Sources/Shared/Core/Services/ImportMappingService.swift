import Foundation

public enum ImportFormat {
    case csv
    case json
    case sql
}

public struct DetectedField {
    public let name: String
    public let sampleValues: [String]

    public init(name: String, sampleValues: [String]) {
        self.name = name
        self.sampleValues = sampleValues
    }
}

public protocol ImportMappingServiceProtocol {
    func parseCSV(fileURL: URL) async throws -> (headers: [String], rows: [[String]])
    func parseJSON(fileURL: URL) async throws -> [[String: Any]]
    func detectFields(from headers: [String]) -> [DetectedField]
    func detectFields(from jsonObjects: [[String: Any]]) -> [DetectedField]
    func suggestMapping(sourceField: String, targetType: ImportTargetType) -> String?
}

public class ImportMappingService: ImportMappingServiceProtocol {

    public init() {}

    public func parseCSV(fileURL: URL) async throws -> (headers: [String], rows: [[String]]) {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }

        guard !lines.isEmpty else {
            throw ImportError.emptyFile
        }

        // Parse header
        let headers = parseCSVLine(lines[0])

        // Parse rows
        let rows = lines.dropFirst().map { parseCSVLine($0) }

        return (headers, Array(rows))
    }

    public func parseJSON(fileURL: URL) async throws -> [[String: Any]] {
        let data = try Data(contentsOf: fileURL)

        guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            throw ImportError.invalidFormat
        }

        return jsonArray
    }

    public func detectFields(from headers: [String]) -> [DetectedField] {
        headers.map { header in
            DetectedField(name: header, sampleValues: [])
        }
    }

    public func detectFields(from jsonObjects: [[String: Any]]) -> [DetectedField] {
        guard let firstObject = jsonObjects.first else {
            return []
        }

        return firstObject.keys.map { key in
            let sampleValues = jsonObjects.prefix(3).compactMap { obj in
                if let value = obj[key] {
                    return String(describing: value)
                }
                return nil
            }
            return DetectedField(name: key, sampleValues: sampleValues)
        }
    }

    public func suggestMapping(sourceField: String, targetType: ImportTargetType) -> String? {
        let lowercased = sourceField.lowercased()

        switch targetType {
        case .item:
            return suggestItemFieldMapping(lowercased)
        case .sale:
            return suggestSaleFieldMapping(lowercased)
        case .purchase:
            return suggestPurchaseFieldMapping(lowercased)
        }
    }

    // MARK: - Private Helpers

    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }

        fields.append(currentField.trimmingCharacters(in: .whitespaces))
        return fields
    }

    private func suggestItemFieldMapping(_ lowercased: String) -> String? {
        if lowercased.contains("title") || lowercased.contains("name")
            || lowercased.contains("product")
        {
            return "title"
        } else if lowercased.contains("sku") || lowercased.contains("id") {
            return "sku"
        } else if lowercased.contains("category") {
            return "category"
        } else if lowercased.contains("price") || lowercased.contains("cost") {
            return "purchasePrice"
        } else if lowercased.contains("quantity") || lowercased.contains("stock") {
            return "quantity"
        } else if lowercased.contains("condition") {
            return "condition"
        } else if lowercased.contains("status") {
            return "status"
        } else if lowercased.contains("brand") {
            return "brand"
        } else if lowercased.contains("date") && lowercased.contains("add") {
            return "dateAdded"
        } else if lowercased.contains("note") {
            return "notes"
        }
        return nil
    }

    private func suggestSaleFieldMapping(_ lowercased: String) -> String? {
        if lowercased.contains("platform") {
            return "platform"
        } else if lowercased.contains("sold") && lowercased.contains("price") {
            return "soldPrice"
        } else if lowercased.contains("fee") {
            return "fees"
        } else if lowercased.contains("buyer") {
            return "buyer"
        } else if lowercased.contains("date") && lowercased.contains("sold") {
            return "dateSold"
        }
        return nil
    }

    private func suggestPurchaseFieldMapping(_ lowercased: String) -> String? {
        if lowercased.contains("supplier") {
            return "supplier"
        } else if lowercased.contains("batch") {
            return "batchName"
        } else if lowercased.contains("cost") {
            return "cost"
        } else if lowercased.contains("date") && lowercased.contains("purchase") {
            return "datePurchased"
        }
        return nil
    }
}

public enum ImportError: LocalizedError {
    case emptyFile
    case invalidFormat
    case mappingFailed

    public var errorDescription: String? {
        switch self {
        case .emptyFile: return "The file is empty"
        case .invalidFormat: return "Invalid file format"
        case .mappingFailed: return "Failed to map fields"
        }
    }
}
