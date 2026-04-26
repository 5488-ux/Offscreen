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

