import Foundation

#if canImport(FamilyControls)
import FamilyControls
#endif

@MainActor
final class ScreenTimeManager: ObservableObject {
    @Published var statusText = "未授权"

    #if canImport(FamilyControls)
    @Published var restrictedSelection = FamilyActivitySelection()
    @Published var whitelistSelection = FamilyActivitySelection()

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            statusText = "已授权"
        } catch {
            statusText = "授权失败：\(error.localizedDescription)"
        }
    }

    var authorizationApproved: Bool {
        AuthorizationCenter.shared.authorizationStatus == .approved
    }
    #else
    func requestAuthorization() async {
        statusText = "当前构建不可用 Screen Time 框架。"
    }

    var authorizationApproved: Bool { false }
    #endif
}
