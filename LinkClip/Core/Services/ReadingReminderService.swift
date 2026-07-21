import UserNotifications

enum ReadingReminderError: LocalizedError {
    case notificationsDisabled

    var errorDescription: String? {
        String(localized: "알림 권한이 필요합니다.")
    }
}

enum ReadingReminderService {
    static func schedule(linkID: UUID, title: String, date: Date) async throws {
        let center = UNUserNotificationCenter.current()
        guard try await center.requestAuthorization(options: [.alert, .sound]) else {
            throw ReadingReminderError.notificationsDisabled
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "저장한 링크를 읽어볼까요?")
        content.body = title
        content.sound = .default
        content.userInfo = [
            "type": "reading_reminder",
            "link_id": linkID.uuidString,
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let request = UNNotificationRequest(
            identifier: identifier(for: linkID),
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: linkID)])
        try await center.add(request)
        var dates = UserDefaults.shared.linkReminderDates
        dates[linkID] = date
        UserDefaults.shared.linkReminderDates = dates
    }

    static func cancel(linkID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier(for: linkID)]
        )
        var dates = UserDefaults.shared.linkReminderDates
        dates.removeValue(forKey: linkID)
        UserDefaults.shared.linkReminderDates = dates
    }

    static func cancelAll() {
        let identifiers = UserDefaults.shared.linkReminderDates.keys.map(identifier(for:))
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
        UserDefaults.shared.linkReminderDates = [:]
    }

    private static func identifier(for linkID: UUID) -> String {
        "reading-reminder-\(linkID.uuidString)"
    }
}
