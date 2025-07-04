import Foundation

public class CacheManager {
    public static let shared = CacheManager()
    private var cache: [String: Any] = [:]
    private var timestamps: [String: Date] = [:]
    private init() {}
    
    public func get<T: Codable>(key: String, type: T.Type) async -> T? {
        return cache[key] as? T
    }
    
    public func set<T: Codable>(key: String, value: T) async {
        cache[key] = value
        timestamps[key] = Date()
    }
    
    public func isExpired(key: String, ttl: TimeInterval) -> Bool {
        guard let timestamp = timestamps[key] else { return true }
        return Date().timeIntervalSince(timestamp) > ttl
    }
    
    /// Remove a cached value by key
    public func remove(key: String) async {
        cache.removeValue(forKey: key)
        timestamps.removeValue(forKey: key)
    }
} 