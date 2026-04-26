import Foundation

#if canImport(FamilyControls) && canImport(ManagedSettings)
import FamilyControls
import ManagedSettings
#endif

@MainActor
final class RestrictionManager: ObservableObject {
    @Published var isShieldActive = false
    @Published var lastMessage = "Restrictions are inactive."

    #if canImport(FamilyControls) && canImport(ManagedSettings)
    private let store = ManagedSettingsStore()

    func applyRestrictions(selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        isShieldActive = true
        lastMessage = "Restrictions applied."
    }

    func clearRestrictions() {
        store.clearAllSettings()
        isShieldActive = false
        lastMessage = "Restrictions cleared."
    }
    #else
    func applyRestrictions() {
        isShieldActive = false
        lastMessage = "ManagedSettings is unavailable in this build."
    }

    func clearRestrictions() {
        isShieldActive = false
        lastMessage = "Restrictions cleared locally."
    }
    #endif
}

