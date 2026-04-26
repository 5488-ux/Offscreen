import SwiftUI

@main
struct OffscreenApp: App {
    @StateObject private var store = OffscreenStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}

