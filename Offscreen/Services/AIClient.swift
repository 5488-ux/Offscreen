import Foundation

struct AIMessage: Codable {
    var role: String
    var content: String
}

struct AIChatRequest: Codable {
    var model: String
    var messages: [AIMessage]
    var temperature: Double = 0.2
}

struct AIPlanResult: Codable, Equatable {
    var dailyLimitMinutes: [Int]
    var coachSummary: String
}

private struct AIChatChoice: Decodable {
    let message: AIMessage
}

private struct AIChatResponse: Decodable {
    let choices: [AIChatChoice]
}

final class AIClient {
    private let settings: AISettings
    private let apiKey: String

    init(settings: AISettings, apiKey: String) {
        self.settings = settings
        self.apiKey = apiKey
    }

    func makePlanPrompt(summary: UsageSummary) -> String {
        """
        Create a 30 day phone withdrawal plan for Offscreen and return strict JSON only.
        Total screen minutes: \(summary.totalScreenMinutes)
        Entertainment minutes: \(summary.entertainmentMinutes)
        Social minutes: \(summary.socialMinutes)
        Game minutes: \(summary.gameMinutes)
        Over limit: \(summary.isOverLimit)
        JSON fields: dailyLimitMinutes array of exactly 30 Int values, coachSummary String.
        """
    }

    func generatePlan(goal: UserGoal, summary: UsageSummary) async throws -> AIPlanResult {
        let prompt = """
        \(makePlanPrompt(summary: summary))
        Current daily entertainment minutes: \(goal.currentDailyMinutes)
        Target final daily minutes: \(goal.targetDailyMinutes)
        Severity: \(goal.severity.rawValue)
        Motivation: \(goal.motivation)
        Limits must gradually move toward the target without dropping below it.
        """
        let content = try await complete(
            system: "You are Offscreen's behavior-change planner. Return valid compact JSON only.",
            user: prompt
        )
        let data = try Self.jsonObjectData(from: content)
        return try JSONDecoder().decode(AIPlanResult.self, from: data)
    }

    func complete(system: String, user: String) async throws -> String {
        let base = settings.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(base)/chat/completions") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(AIChatRequest(
            model: settings.modelName,
            messages: [
                AIMessage(role: "system", content: system),
                AIMessage(role: "user", content: user)
            ]
        ))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(AIChatResponse.self, from: data)
        return decoded.choices.first?.message.content ?? ""
    }

    func reviewDailyCheckIn(text: String, usage: UsageSummary, health: HealthRewardSummary?) async throws -> AIReviewResult {
        let healthText = health.map { "steps=\($0.steps), exerciseMinutes=\($0.exerciseMinutes), reward=\($0.rewardMinutes)" } ?? "not available"
        let prompt = """
        Review today's Offscreen check-in and return strict JSON only.
        Text: \(text)
        Usage total=\(usage.totalScreenMinutes), entertainment=\(usage.entertainmentMinutes), overLimit=\(usage.isOverLimit)
        Health: \(healthText)
        JSON fields: completionScore Int, summaryQuality String, imageValid Bool, tomorrowAdjustmentMinutes Int, extendPlanDays Int, reason String.
        """
        let content = try await complete(
            system: "You are Offscreen's strict but fair habit coach. Return valid compact JSON only.",
            user: prompt
        )
        let data = try Self.jsonObjectData(from: content)
        return try JSONDecoder().decode(AIReviewResult.self, from: data)
    }

    private static func jsonObjectData(from content: String) throws -> Data {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("{"), trimmed.hasSuffix("}") {
            return Data(trimmed.utf8)
        }

        guard let start = trimmed.firstIndex(of: "{"), let end = trimmed.lastIndex(of: "}"), start <= end else {
            throw URLError(.cannotParseResponse)
        }

        return Data(trimmed[start...end].utf8)
    }
}
