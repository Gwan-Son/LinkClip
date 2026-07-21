import UIKit
import UserNotifications

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Task { await AppAttestManager.shared.prepareSession() }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        let value = token.map { String(format: "%02x", $0) }.joined()
        Task {
            await AppAttestManager.shared.prepareSession()
            try? await SummaryAPI.registerDeviceToken(value)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        guard let identifier = userInfo["job_id"] as? String
                ?? userInfo["link_id"] as? String
                ?? userInfo["id"] as? String else { return }
        UserDefaults.shared.set(identifier, forKey: UserDefaults.Keys.pendingSummaryNotificationID)
        UserDefaults.shared.set(
            userInfo["type"] as? String,
            forKey: UserDefaults.Keys.pendingNotificationType
        )
        NotificationCenter.default.post(name: .summaryNotificationTapped, object: nil)
    }
}

extension Notification.Name {
    static let summaryNotificationTapped = Notification.Name("SummaryNotificationTapped")
}

enum PushNotificationService {
    @MainActor
    static func enable() async {
        guard (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])) == true else { return }
        UIApplication.shared.registerForRemoteNotifications()
    }
}
