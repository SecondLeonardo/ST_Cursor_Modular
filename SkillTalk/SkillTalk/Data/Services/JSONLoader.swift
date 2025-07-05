//
//  JSONLoader.swift
//  SkillTalk
//

import Foundation

/// Utility for loading and parsing JSON files
enum JSONLoader {
    /// Error types for JSON loading
    enum LoaderError: Error {
        case fileNotFound(String)
        case invalidJSON(String)
        case decodingError(Error)
    }
    
    /// Load and decode a JSON file from the bundle
    static func load<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw LoaderError.fileNotFound(filename)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw LoaderError.decodingError(error)
        } catch {
            throw LoaderError.invalidJSON(error.localizedDescription)
        }
    }
    
    /// Load and decode a JSON file from a specific directory
    static func load<T: Decodable>(_ type: T.Type, from directory: String, filename: String) throws -> T {
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let directoryURL = bundleURL.appendingPathComponent(directory)
        let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw LoaderError.fileNotFound("\(directory)/\(filename).json")
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw LoaderError.decodingError(error)
        } catch {
            throw LoaderError.invalidJSON(error.localizedDescription)
        }
    }
    
    /// Load all JSON files from a directory that match a pattern
    static func loadAll<T: Decodable>(_ type: T.Type, from directory: String, matching pattern: String = "*.json") throws -> [T] {
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let directoryURL = bundleURL.appendingPathComponent(directory)
        
        guard let enumerator = fileManager.enumerator(at: directoryURL,
                                                     includingPropertiesForKeys: [.isRegularFileKey],
                                                     options: [.skipsHiddenFiles]) else {
            return []
        }
        
        var results: [T] = []
        
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "json" else { continue }
            
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode(T.self, from: data)
                results.append(decoded)
            } catch {
                print("Error decoding \(fileURL.lastPathComponent): \(error)")
                continue
            }
        }
        
        return results
    }
    
    /// Save data to a JSON file
    static func save<T: Encodable>(_ data: T, to filename: String, in directory: String? = nil) throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let jsonData = try encoder.encode(data)
        
        var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if let directory = directory {
            fileURL.appendPathComponent(directory)
            try FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true)
        }
        fileURL.appendPathComponent(filename)
        fileURL.appendPathExtension("json")
        
        try jsonData.write(to: fileURL)
    }
} 