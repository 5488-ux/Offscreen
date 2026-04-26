import Foundation

struct AIMessage: Codable {
    var role: String
    var content: String
}

struct AIChatRequest: Codable {
    var model: String
    var messages: [AIMessage]
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
        Create a 30 day phone withdrawal plan for Offscreen.
        Total screen minutes: \(summary.totalScreenMinutes)
        Entertainment minutes: \(summary.entertainmentMinutes)
        Social minutes: \(summary.socialMinutes)
        Game minutes: \(summary.gameMinutes)
        Over limit: \(summary.isOverLimit)
        Return compact JSON with daily limits and one daily task.
        """
    }
}

