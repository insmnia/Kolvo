//
//  PersistenceService.swift
//  Kolvo
//

import Foundation

final class PersistenceService {
    static let shared = PersistenceService()

    private init() {}

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var fileURL: URL {
        documentsDirectory.appendingPathComponent("counters.json")
    }

    func load() -> [Counter] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Counter].self, from: data)
        } catch {
            print("Failed to load counters: \(error)")
            return []
        }
    }

    func save(_ counters: [Counter]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(counters)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save counters: \(error)")
        }
    }
}
