import AVFoundation
import Combine
import Foundation

@MainActor
final class VideoWatchTracker: ObservableObject {
    @Published var validSeconds: Int
    @Published var isCompleted: Bool
    @Published var player: AVPlayer?
    @Published var message = ""

    let kind: VideoKind
    private let requiredSeconds: Int
    private var timer: AnyCancellable?

    init(kind: VideoKind, existingProgress: VideoProgress) {
        self.kind = kind
        self.requiredSeconds = kind.requiredSeconds
        self.validSeconds = existingProgress.watchedValidSeconds
        self.isCompleted = existingProgress.completed
        self.player = Self.makePlayer(kind: kind)
        if player == nil {
            message = "Add \(kind.bundledFileName).mp4 to the app bundle."
        }
    }

    func start() {
        guard let player else { return }
        player.play()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.tick()
                }
            }
    }

    func pause() {
        player?.pause()
        timer?.cancel()
        timer = nil
    }

    func stop() {
        pause()
        player?.seek(to: .zero)
    }

    private func tick() {
        guard let player, player.rate > 0, abs(player.rate - 1.0) < 0.01 else { return }
        validSeconds = min(requiredSeconds, validSeconds + 1)
        isCompleted = validSeconds >= requiredSeconds
        if isCompleted {
            pause()
        }
    }

    private static func makePlayer(kind: VideoKind) -> AVPlayer? {
        guard let url = Bundle.main.url(forResource: kind.bundledFileName, withExtension: "mp4") else {
            return nil
        }
        return AVPlayer(url: url)
    }
}

