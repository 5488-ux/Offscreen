import Foundation

@MainActor
final class RestrictionManager: ObservableObject {
    @Published var isShieldActive = false
    @Published var lastMessage = "淘宝证书版未启用 Screen Time 限制。"

    func clearRestrictions() {
        isShieldActive = false
        lastMessage = "已清除本地限制状态。"
    }
}
