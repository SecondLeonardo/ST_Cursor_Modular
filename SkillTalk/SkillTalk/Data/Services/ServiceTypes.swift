import Foundation

/// Service type enumeration
public enum ServiceType: String, CaseIterable {
    case authentication = "Authentication"
    case database = "Database"
    case storage = "Storage"
    case realtimeMessaging = "Realtime Messaging"
    case voiceVideo = "Voice/Video"
    case translation = "Translation"
    case pushNotifications = "Push Notifications"
}

public enum ServiceProvider: String, CaseIterable {
    case firebase = "Firebase"
    case supabase = "Supabase"
    case agora = "Agora"
    case dailyCo = "Daily.co"
    case pusher = "Pusher"
    case ably = "Ably"
    case cloudflareR2 = "Cloudflare R2"
    case libreTranslate = "LibreTranslate"
    case deepL = "DeepL"
    case fcm = "FCM"
    case oneSignal = "OneSignal"
    case revenueCat = "RevenueCat"
    case googlePlayBilling = "Google Play Billing"
    case hundredMs = "100ms.live"
}

public enum ServiceHealthStatus: String {
    case healthy = "Healthy"
    case degraded = "Degraded"
    case failed = "Failed"
    case unknown = "Unknown"
} 