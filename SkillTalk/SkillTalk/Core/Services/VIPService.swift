import Foundation

// MARK: - VIP Service Protocol
protocol VIPServiceProtocol {
    var isVIPUser: Bool { get }
    var maxLanguagesAllowed: Int { get }
    func canSelectAdditionalLanguage(currentCount: Int) -> Bool
    func getVIPUpgradeMessage() -> String
}

// MARK: - VIP Service Implementation
class VIPService: VIPServiceProtocol {
    static let shared = VIPService()
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let vipKey = "user_vip_status"
    
    var isVIPUser: Bool {
        get {
            return userDefaults.bool(forKey: vipKey)
        }
        set {
            userDefaults.set(newValue, forKey: vipKey)
        }
    }
    
    var maxLanguagesAllowed: Int {
        return isVIPUser ? 5 : 1 // VIP users can select up to 5 languages, regular users only 1
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    func canSelectAdditionalLanguage(currentCount: Int) -> Bool {
        return currentCount < maxLanguagesAllowed
    }
    
    func getVIPUpgradeMessage() -> String {
        return "Upgrade to VIP to select multiple languages and unlock premium features!"
    }
    
    // MARK: - VIP Management (for testing)
    
    func upgradeToVIP() {
        isVIPUser = true
        print("👑 User upgraded to VIP")
    }
    
    func downgradeFromVIP() {
        isVIPUser = false
        print("👤 User downgraded from VIP")
    }
    
    // MARK: - Language Selection Tracking
    
    func getSelectedLanguages() -> [String] {
        return userDefaults.stringArray(forKey: "selected_languages") ?? []
    }
    
    func addSelectedLanguage(_ language: String) {
        var languages = getSelectedLanguages()
        if !languages.contains(language) {
            languages.append(language)
            userDefaults.set(languages, forKey: "selected_languages")
        }
    }
    
    func removeSelectedLanguage(_ language: String) {
        var languages = getSelectedLanguages()
        languages.removeAll { $0 == language }
        userDefaults.set(languages, forKey: "selected_languages")
    }
    
    func clearSelectedLanguages() {
        userDefaults.removeObject(forKey: "selected_languages")
    }
} 