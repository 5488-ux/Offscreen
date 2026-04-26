import Foundation

#if canImport(FamilyControls)
import FamilyControls
#endif

@MainActor
final class ScreenTimeManager: ObservableObject {
    @Published var statusText = "Not authorized"

    #if canImport(FamilyControls)
    @Published var restrictedSelection = FamilyActivitySelection()
    @Published var whitelistSelection = FamilyActivitySelection()

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            statusText = "Authorized"
        } catch {
            statusText = "Authorization failed: \(error.localizedDescription)"
        }
    }

    var authorizationApproved: Bool {
        AuthorizationCenter.shared.authorizationStatus == .approved
    }
    #else
    func requestAuthorization() async {
        statusText = "Screen Time frameworks unavailable in this build."
    }

    var authorizationApproved: Bool { false }
    #endif
}

