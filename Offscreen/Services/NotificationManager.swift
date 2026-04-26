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
        content.title = "Offscreen 每日打卡"
        content.body = "写下今晚的总结，并完成明天的戒手机计划。"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-check-in", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleSessionWarning(after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "还剩 10 分钟"
        content.body = "这次玩手机时间快结束了。"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "play-session-warning", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
