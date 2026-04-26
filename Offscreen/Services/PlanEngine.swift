import Foundation

enum PlanEngine {
    static func makeDefaultPlan(startDate: Date = Date()) -> OffscreenPlan {
        let calendar = Calendar.current
        let limits = stride(from: 120, through: 15, by: -4).map { $0 }
        let paddedLimits = limits + Array(repeating: 15, count: max(0, 30 - limits.count))

        let days = paddedLimits.prefix(30).enumerated().map { index, limit in
            PlanDay(
                dayIndex: index + 1,
                date: calendar.date(byAdding: .day, value: index, to: calendar.startOfDay(for: startDate)) ?? startDate,
                baseLimitMinutes: limit,
                rewardMinutes: 0,
                penaltyMinutes: 0,
                usedMinutes: 0,
                completedCheckIn: false,
                completedVideo: false,
                completedHealthGoal: false
            )
        }

        return OffscreenPlan(
            startDate: calendar.startOfDay(for: startDate),
            status: .active,
            targetFinalMinutes: 15,
            extendedDays: 0,
            days: days
        )
    }
}
