import AVKit
import SwiftUI

struct VideoWatchView: View {
    @EnvironmentObject private var store: OffscreenStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tracker: VideoWatchTracker

    init(kind: VideoKind) {
        _tracker = StateObject(wrappedValue: VideoWatchTracker(
            kind: kind,
            existingProgress: VideoProgress(kind: kind, date: Date(), watchedValidSeconds: 0, requiredSeconds: kind.requiredSeconds, completed: false, updatedAt: Date())
        ))
    }

    var body: some View {
        VStack(spacing: 16) {
            if let player = tracker.player {
                VideoPlayer(player: player)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .background(Color.black)
            } else {
                ContentUnavailableView("Video missing", systemImage: "film", description: Text(tracker.message))
            }

            ProgressView(value: Double(tracker.validSeconds), total: Double(tracker.kind.requiredSeconds))
                .padding(.horizontal)

            Text("\(tracker.validSeconds / 60)m \(tracker.validSeconds % 60)s / \(tracker.kind.requiredSeconds / 60)m")
                .font(.headline)

            HStack {
                Button("Play") {
                    tracker.start()
                }
                .buttonStyle(.borderedProminent)

                Button("Pause") {
                    tracker.pause()
                    store.updateVideo(kind: tracker.kind, validSeconds: tracker.validSeconds)
                }
                .buttonStyle(.bordered)
            }

            if tracker.isCompleted {
                Text("Completed")
                    .foregroundStyle(.green)
            }

            Spacer()
        }
        .padding(.top)
        .navigationTitle(tracker.kind.title)
        .onAppear {
            let progress = store.progress(for: tracker.kind)
            tracker.validSeconds = progress.watchedValidSeconds
            tracker.isCompleted = progress.completed
        }
        .onChange(of: tracker.validSeconds) { _, newValue in
            store.updateVideo(kind: tracker.kind, validSeconds: newValue)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                tracker.pause()
                store.updateVideo(kind: tracker.kind, validSeconds: tracker.validSeconds)
            }
        }
        .onDisappear {
            tracker.pause()
            store.updateVideo(kind: tracker.kind, validSeconds: tracker.validSeconds)
        }
    }
}

