import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleDailyCheckIn() {
        var date = DateComponents()
        date.hour = 21
        date.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Offscreen check-in"
        content.body = "Write tonight's reflection and finish your plan for tomorrow."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-check-in", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleSessionWarning(after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "10 minutes left"
        content.body = "Your Offscreen play session is almost over."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "play-session-warning", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

