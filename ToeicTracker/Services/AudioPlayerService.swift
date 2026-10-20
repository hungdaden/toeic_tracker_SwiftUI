import Foundation
import AVFoundation
import Combine

public final class AudioPlayerService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    public static let shared = AudioPlayerService()

    @Published public var isPlaying: Bool = false
    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var currentUrl: URL?

    public var onPlaybackFinished: (() -> Void)?

    private var player: AVAudioPlayer?
    private var timer: Timer?

    private override init() {
        super.init()
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error)")
        }
    }

    public func play(url: URL) {
        if currentUrl == url && player != nil {
            player?.play()
            isPlaying = true
            startTimer()
            return
        }

        stop()
        currentUrl = url

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            duration = player?.duration ?? 0
            currentTime = 0
            isPlaying = true
            startTimer()
        } catch {
            print("Error initializing audio player for \(url): \(error)")
            isPlaying = false
        }
    }

    public func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }

    public func resume() {
        player?.play()
        isPlaying = true
        startTimer()
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    public func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }

    public func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        stopTimer()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTime = player.currentTime
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - AVAudioPlayerDelegate
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopTimer()
        onPlaybackFinished?()
    }
}
