import Foundation

#if canImport(FamilyControls) && canImport(ManagedSettings)
import FamilyControls
import ManagedSettings
#endif

@MainActor
final class RestrictionManager: ObservableObject {
    @Published var isShieldActive = false
    @Published var lastMessage = "当前未开启限制。"

    #if canImport(FamilyControls) && canImport(ManagedSettings)
    private let store = ManagedSettingsStore()

    func applyRestrictions(selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        isShieldActive = true
        lastMessage = "已开启限制。"
    }

    func clearRestrictions() {
        store.clearAllSettings()
        isShieldActive = false
        lastMessage = "已解除限制。"
    }
    #else
    func applyRestrictions() {
        isShieldActive = false
        lastMessage = "当前构建不可用 ManagedSettings。"
    }

    func clearRestrictions() {
        isShieldActive = false
        lastMessage = "已在本地清除限制状态。"
    }
    #endif
}
