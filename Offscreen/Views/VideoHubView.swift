import SwiftUI

struct VideoHubView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Daily 5 minute video") {
                    VideoWatchView(kind: .daily)
                }
                NavigationLink("90 minute cancellation cooldown") {
                    VideoWatchView(kind: .cancellation)
                }
            }
            .navigationTitle("Video")
        }
    }
}

