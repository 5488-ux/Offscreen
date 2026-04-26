import Foundation

enum PlanEngine {
    static func makeDefaultPlan(startDate: Date = Date(), currentMinutes: Int = 120, targetMinutes: Int = 15) -> OffscreenPlan {
        let calendar = Calendar.current
        let start = max(currentMinutes, targetMinutes)
        let target = max(5, targetMinutes)
        let step = max(1, Int(ceil(Double(start - target) / 29.0)))
        let limits = (0..<30).map { day in
            max(target, start - day * step)
        }

        let days = limits.enumerated().map { index, limit in
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
            targetFinalMinutes: target,
            extendedDays: 0,
            days: days
        )
    }
}
