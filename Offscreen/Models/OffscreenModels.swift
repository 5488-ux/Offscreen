import Foundation

struct AISettings: Codable, Equatable {
    var baseURL: String = "https://api.openai.com/v1"
    var modelName: String = "gpt-4.1-mini"
    var allowsScreenSummaryAnalysis: Bool = true
    var allowsDailyReflectionAnalysis: Bool = true
    var hasAPIKey: Bool = false
}

struct PlanDay: Codable, Identifiable, Equatable {
    var id = UUID()
    var dayIndex: Int
    var date: Date
    var baseLimitMinutes: Int
    var rewardMinutes: Int
    var penaltyMinutes: Int
    var usedMinutes: Int
    var completedCheckIn: Bool
    var completedVideo: Bool
    var completedHealthGoal: Bool = false

    var finalLimitMinutes: Int {
        max(15, baseLimitMinutes + rewardMinutes - penaltyMinutes)
    }

    var remainingMinutes: Int {
        max(0, finalLimitMinutes - usedMinutes)
    }
}

struct OffscreenPlan: Codable, Equatable {
    var id = UUID()
    var startDate: Date
    var status: PlanStatus
    var targetFinalMinutes: Int
    var extendedDays: Int
    var days: [PlanDay]

    var today: PlanDay {
        days.first { Calendar.current.isDateInToday($0.date) } ?? days.first!
    }
}

enum PlanStatus: String, Codable, CaseIterable {
    case active
    case paused
    case cancelled
    case completed
}

struct DailyCheckIn: Codable, Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var text: String
    var imagePath: String?
    var aiScore: Int?
    var aiFeedback: String?
}

struct AIReviewResult: Codable, Equatable {
    var completionScore: Int
    var summaryQuality: String
    var imageValid: Bool
    var tomorrowAdjustmentMinutes: Int
    var extendPlanDays: Int
    var reason: String
}

struct UsageSummary: Codable, Equatable {
    var date: Date
    var totalScreenMinutes: Int
    var entertainmentMinutes: Int
    var socialMinutes: Int
    var gameMinutes: Int
    var isOverLimit: Bool
}

struct HealthRewardSummary: Codable, Equatable {
    var date: Date
    var steps: Int
    var exerciseMinutes: Int
    var activeEnergyKcal: Double

    var rewardMinutes: Int {
        var reward = 0
        if steps >= 3_000 { reward += 3 }
        if steps >= 6_000 { reward += 2 }
        if exerciseMinutes >= 30 { reward += 10 }
        return min(reward, 15)
    }
}

enum VideoKind: String, Codable, CaseIterable, Identifiable {
    case daily
    case cancellation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: "Daily video"
        case .cancellation: "Cancellation cooldown"
        }
    }

    var requiredSeconds: Int {
        switch self {
        case .daily: 5 * 60
        case .cancellation: 90 * 60
        }
    }

    var bundledFileName: String {
        switch self {
        case .daily: "daily-video"
        case .cancellation: "cancel-cooldown"
        }
    }
}

struct VideoProgress: Codable, Identifiable, Equatable {
    var id = UUID()
    var kind: VideoKind
    var date: Date
    var watchedValidSeconds: Int
    var requiredSeconds: Int
    var completed: Bool
    var updatedAt: Date

    var remainingSeconds: Int {
        max(0, requiredSeconds - watchedValidSeconds)
    }

    var fraction: Double {
        guard requiredSeconds > 0 else { return 0 }
        return min(1, Double(watchedValidSeconds) / Double(requiredSeconds))
    }
}

struct PlaySessionState: Codable, Equatable {
    var isActive: Bool
    var startedAt: Date?
    var plannedMinutes: Int
    var endsAt: Date?
}

enum PenaltyType: String, Codable, CaseIterable {
    case missedCheckIn
    case missedVideo
    case overLimit
    case revokedPermission
    case cancelAttempt
}

struct PenaltyEvent: Codable, Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var type: PenaltyType
    var penaltyMinutes: Int
    var extendDays: Int
    var note: String
}
