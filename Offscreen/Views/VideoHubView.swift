import SwiftUI

struct VideoHubView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("每日 5 分钟短片") {
                    VideoWatchView(kind: .daily)
                }
                NavigationLink("90 分钟取消冷静期") {
                    VideoWatchView(kind: .cancellation)
                }
            }
            .navigationTitle("短片")
        }
    }
}
