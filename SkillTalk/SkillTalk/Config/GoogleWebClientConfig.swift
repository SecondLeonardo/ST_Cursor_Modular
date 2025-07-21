import Foundation

struct GoogleWebClientConfig {
    static var clientID: String {
        guard let value = ProcessInfo.processInfo.environment["GOOGLE_CLIENT_ID"] else {
            print("[DEBUG] GOOGLE_CLIENT_ID not set in environment.")
            return ""
        }
        return value
    }
    
    static var clientSecret: String {
        guard let value = ProcessInfo.processInfo.environment["GOOGLE_CLIENT_SECRET"] else {
            print("[DEBUG] GOOGLE_CLIENT_SECRET not set in environment.")
            return ""
        }
        return value
    }
}

// Usage Example:
// let clientID = GoogleWebClientConfig.clientID
// let clientSecret = GoogleWebClientConfig.clientSecret

