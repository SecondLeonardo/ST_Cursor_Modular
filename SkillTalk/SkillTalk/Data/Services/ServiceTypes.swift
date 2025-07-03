import Foundation

/// Service type enumeration
enum ServiceType: String, CaseIterable {
    case authentication = "Authentication"
    case database = "Database"
    case storage = "Storage"
    case realtime = "Realtime"
    case realtimeMessaging = "RealtimeMessaging"
    case pushNotifications = "PushNotifications"
    case voiceVideo = "VoiceVideo"
    case translation = "Translation"
    case videoConferencing = "VideoConferencing"
    case voiceRoom = "VoiceRoom"
    case analytics = "Analytics"
    case monitoring = "Monitoring"
}

enum ServiceProvider: String, CaseIterable {
    case firebase = "Firebase"
    case supabase = "Supabase"
    case agora = "Agora"
    case dailyco = "Daily.co"
    case pusher = "Pusher"
    case ably = "Ably"
    case cloudflareR2 = "Cloudflare R2"
    case libreTranslate = "LibreTranslate"
    case deepL = "DeepL"
    case fcm = "FCM"
    case revenueCat = "RevenueCat"
    case googlePlayBilling = "Google Play Billing"
    case hundredMs = "100ms.live"
    case googleTranslate = "Google Translate"
    case onesignal = "OneSignal" // Alias for oneSignal
}

enum ServiceHealthStatus: String {
    case healthy = "Healthy"
    case degraded = "Degraded"
    case failed = "Failed"
    case unknown = "Unknown"
} 