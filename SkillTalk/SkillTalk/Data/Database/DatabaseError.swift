import Foundation

enum DatabaseError: Error, LocalizedError {
    case invalidData
    case connectionFailed
    case queryFailed
    case notFound
    case unauthorized
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data format"
        case .connectionFailed:
            return "Database connection failed"
        case .queryFailed:
            return "Database query failed"
        case .notFound:
            return "Data not found"
        case .unauthorized:
            return "Unauthorized access"
        case .timeout:
            return "Database operation timed out"
        }
    }
} 