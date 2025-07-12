import Foundation
import Security

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    // MARK: - Keychain Keys
    private let accessTokenKey = "SkillTalkAccessToken"
    private let refreshTokenKey = "SkillTalkRefreshToken"

    // MARK: - Store Token
    func storeAccessToken(_ token: String) {
        store(token, forKey: accessTokenKey)
    }
    func storeRefreshToken(_ token: String) {
        store(token, forKey: refreshTokenKey)
    }

    // MARK: - Retrieve Token
    func getAccessToken() -> String? {
        return retrieve(forKey: accessTokenKey)
    }
    func getRefreshToken() -> String? {
        return retrieve(forKey: refreshTokenKey)
    }

    // MARK: - Remove Tokens
    func clearTokens() {
        remove(forKey: accessTokenKey)
        remove(forKey: refreshTokenKey)
    }

    // MARK: - Keychain Helpers
    private func store(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func retrieve(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    private func remove(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
} 