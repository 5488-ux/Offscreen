import Combine
import Foundation

@MainActor
final class OffscreenStore: ObservableObject {
    @Published var aiSettings: AISettings
    @Published var userGoal: UserGoal
    @Published var plan: OffscreenPlan
    @Published var checkIns: [DailyCheckIn]
    @Published var videoProgress: [VideoProgress]
    @Published var penaltyEvents: [PenaltyEvent]
    @Published var playSession: PlaySessionState
    @Published var healthSummary: HealthRewardSummary?
    @Published var hasCompletedOnboarding: Bool

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        self.aiSettings = Self.load(AISettings.self, key: StorageKey.aiSettings) ?? AISettings()
        self.userGoal = Self.load(UserGoal.self, key: StorageKey.userGoal) ?? UserGoal()
        self.plan = Self.load(OffscreenPlan.self, key: StorageKey.plan) ?? PlanEngine.makeDefaultPlan()
        self.checkIns = Self.load([DailyCheckIn].self, key: StorageKey.checkIns) ?? []
        self.videoProgress = Self.load([VideoProgress].self, key: StorageKey.videoProgress) ?? Self.defaultVideoProgress()
        self.penaltyEvents = Self.load([PenaltyEvent].self, key: StorageKey.penaltyEvents) ?? []
        self.playSession = Self.load(PlaySessionState.self, key: StorageKey.playSession) ?? PlaySessionState(isActive: false, startedAt: nil, plannedMinutes: 0, endsAt: nil)
        self.healthSummary = Self.load(HealthRewardSummary.self, key: StorageKey.healthSummary)
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: StorageKey.hasCompletedOnboarding)
    }

    var today: PlanDay {
        plan.today
    }

    var dailyTasks: [DailyTask] {
        [
            DailyTask(title: "观看每日 5 分钟短片", subtitle: "必须在 App 前台播放才计时", isDone: today.completedVideo, systemImage: "play.rectangle"),
            DailyTask(title: "晚上 9 点打卡", subtitle: "写总结并上传图片后可让 AI 复盘", isDone: today.completedCheckIn, systemImage: "square.and.pencil"),
            DailyTask(title: "完成健康奖励", subtitle: "步数和运动可奖励少量额度", isDone: today.completedHealthGoal, systemImage: "heart"),
            DailyTask(title: "不超出今日额度", subtitle: "超额会减少明天额度或延长计划", isDone: today.usedMinutes <= today.finalLimitMinutes, systemImage: "timer")
        ]
    }

    func saveAISettings(_ settings: AISettings) {
        aiSettings = settings
        save(settings, key: StorageKey.aiSettings)
    }

    func saveUserGoal(_ goal: UserGoal) {
        userGoal = goal
        save(goal, key: StorageKey.userGoal)
        plan = PlanEngine.makeDefaultPlan(startDate: Date(), currentMinutes: goal.currentDailyMinutes, targetMinutes: goal.targetDailyMinutes)
        save(plan, key: StorageKey.plan)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: StorageKey.hasCompletedOnboarding)
    }

    func reopenOnboarding() {
        hasCompletedOnboarding = false
        defaults.set(false, forKey: StorageKey.hasCompletedOnboarding)
    }

    func startPlaySession(minutes: Int) {
        guard minutes > 0 else { return }
        let now = Date()
        playSession = PlaySessionState(
            isActive: true,
            startedAt: now,
            plannedMinutes: minutes,
            endsAt: Calendar.current.date(byAdding: .minute, value: minutes, to: now)
        )
        save(playSession, key: StorageKey.playSession)
    }

    func stopPlaySession(consumedMinutes: Int? = nil) {
        let minutes = consumedMinutes ?? elapsedPlaySessionMinutes()
        playSession = PlaySessionState(isActive: false, startedAt: nil, plannedMinutes: 0, endsAt: nil)
        save(playSession, key: StorageKey.playSession)
        updateToday { day in
            day.usedMinutes = min(day.finalLimitMinutes, day.usedMinutes + max(0, minutes))
        }
    }

    func elapsedPlaySessionMinutes(now: Date = Date()) -> Int {
        guard let startedAt = playSession.startedAt else { return 0 }
        let elapsed = max(0, now.timeIntervalSince(startedAt))
        return min(playSession.plannedMinutes, Int(ceil(elapsed / 60)))
    }

    func addCheckIn(text: String, imagePath: String? = nil, review: AIReviewResult? = nil) {
        let checkIn = DailyCheckIn(
            date: Date(),
            text: text,
            imagePath: imagePath,
            aiScore: review?.completionScore,
            aiFeedback: review?.reason
        )
        checkIns.insert(checkIn, at: 0)
        save(checkIns, key: StorageKey.checkIns)
        updateToday { day in
            day.completedCheckIn = true
        }
    }

    func updateVideo(kind: VideoKind, validSeconds: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let required = kind.requiredSeconds
        if let index = videoProgress.firstIndex(where: { $0.kind == kind && Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            videoProgress[index].watchedValidSeconds = min(required, max(videoProgress[index].watchedValidSeconds, validSeconds))
            videoProgress[index].completed = videoProgress[index].watchedValidSeconds >= required
            videoProgress[index].updatedAt = Date()
        } else {
            videoProgress.append(VideoProgress(kind: kind, date: today, watchedValidSeconds: min(required, validSeconds), requiredSeconds: required, completed: validSeconds >= required, updatedAt: Date()))
        }
        save(videoProgress, key: StorageKey.videoProgress)

        if kind == .daily && validSeconds >= required {
            updateToday { day in
                day.completedVideo = true
            }
        }
    }

    func progress(for kind: VideoKind) -> VideoProgress {
        let today = Calendar.current.startOfDay(for: Date())
        return videoProgress.first { $0.kind == kind && Calendar.current.isDate($0.date, inSameDayAs: today) }
            ?? VideoProgress(kind: kind, date: today, watchedValidSeconds: 0, requiredSeconds: kind.requiredSeconds, completed: false, updatedAt: Date())
    }

    func applyHealthReward(_ summary: HealthRewardSummary) {
        healthSummary = summary
        save(summary, key: StorageKey.healthSummary)
        updateToday { day in
            day.rewardMinutes = min(15, summary.rewardMinutes)
            day.completedHealthGoal = summary.rewardMinutes > 0
        }
    }

    func recordPenalty(_ event: PenaltyEvent) {
        penaltyEvents.insert(event, at: 0)
        save(penaltyEvents, key: StorageKey.penaltyEvents)
        updateToday { day in
            day.penaltyMinutes += event.penaltyMinutes
        }

        if event.extendDays > 0 {
            plan.extendedDays += event.extendDays
            save(plan, key: StorageKey.plan)
        }
    }

    func resetPlan() {
        plan = PlanEngine.makeDefaultPlan(startDate: Date(), currentMinutes: userGoal.currentDailyMinutes, targetMinutes: userGoal.targetDailyMinutes)
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

    private static func defaultVideoProgress() -> [VideoProgress] {
        let today = Calendar.current.startOfDay(for: Date())
        return VideoKind.allCases.map {
            VideoProgress(kind: $0, date: today, watchedValidSeconds: 0, requiredSeconds: $0.requiredSeconds, completed: false, updatedAt: Date())
        }
    }
}

private enum StorageKey {
    static let aiSettings = "offscreen.aiSettings"
    static let userGoal = "offscreen.userGoal"
    static let plan = "offscreen.plan"
    static let checkIns = "offscreen.checkIns"
    static let videoProgress = "offscreen.videoProgress"
    static let penaltyEvents = "offscreen.penaltyEvents"
    static let playSession = "offscreen.playSession"
    static let healthSummary = "offscreen.healthSummary"
    static let hasCompletedOnboarding = "offscreen.hasCompletedOnboarding"
}
