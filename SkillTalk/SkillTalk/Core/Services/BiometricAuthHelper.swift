import Foundation
import LocalAuthentication

final class BiometricAuthHelper {
    static let shared = BiometricAuthHelper()
    private let context = LAContext()

    private init() {}

    /// Checks if biometric authentication is available on device
    func isBiometricAvailable() -> Bool {
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let error = error {
            print("[BiometricAuthHelper] Biometric unavailable: \(error.localizedDescription)")
        }
        return available
    }

    /// Attempts biometric authentication, returns true if successful
    func authenticate(reason: String = "Authenticate to continue") async -> Bool {
        await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if let error = error {
                    print("[BiometricAuthHelper] Biometric auth failed: \(error.localizedDescription)")
                }
                continuation.resume(returning: success)
            }
        }
    }
} 