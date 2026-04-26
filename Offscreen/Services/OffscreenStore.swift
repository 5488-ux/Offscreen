import Foundation

@MainActor
final class OffscreenStore: ObservableObject {
    @Published var aiSettings: AISettings
    @Published var plan: OffscreenPlan
    @Published var checkIns: [DailyCheckIn]
    @Published var isPlaySessionActive: Bool

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        self.aiSettings = Self.load(AISettings.self, key: StorageKey.aiSettings) ?? AISettings()
        self.plan = Self.load(OffscreenPlan.self, key: StorageKey.plan) ?? PlanEngine.makeDefaultPlan()
        self.checkIns = Self.load([DailyCheckIn].self, key: StorageKey.checkIns) ?? []
        self.isPlaySessionActive = UserDefaults.standard.bool(forKey: StorageKey.playSessionActive)
    }

    var today: PlanDay {
        plan.today
    }

    func saveAISettings(_ settings: AISettings) {
        aiSettings = settings
        save(settings, key: StorageKey.aiSettings)
    }

    func startPlaySession(minutes: Int) {
        guard minutes > 0 else { return }
        isPlaySessionActive = true
        defaults.set(true, forKey: StorageKey.playSessionActive)
    }

    func stopPlaySession(consumedMinutes: Int) {
        isPlaySessionActive = false
        defaults.set(false, forKey: StorageKey.playSessionActive)
        updateToday { day in
            day.usedMinutes = min(day.finalLimitMinutes, day.usedMinutes + max(0, consumedMinutes))
        }
    }

    func addCheckIn(text: String) {
        let checkIn = DailyCheckIn(date: Date(), text: text, imagePath: nil, aiScore: nil, aiFeedback: nil)
        checkIns.insert(checkIn, at: 0)
        save(checkIns, key: StorageKey.checkIns)
        updateToday { day in
            day.completedCheckIn = true
        }
    }

    func resetPlan() {
        plan = PlanEngine.makeDefaultPlan()
        save(plan, key: StorageKey.plan)
    }

    private func updateToday(_ mutate: (inout PlanDay) -> Void) {
        guard let index = plan.days.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) else {
            return
        }
        mutate(&plan.days[index])
        save(plan, key: StorageKey.plan)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(type, from: data)
    }
}

private enum StorageKey {
    static let aiSettings = "offscreen.aiSettings"
    static let plan = "offscreen.plan"
    static let checkIns = "offscreen.checkIns"
    static let playSessionActive = "offscreen.playSessionActive"
}

