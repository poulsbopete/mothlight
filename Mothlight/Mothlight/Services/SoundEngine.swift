import AVFoundation
import AudioToolbox
import Foundation

final class SoundEngine {
    static let shared = SoundEngine()

    private var engine = AVAudioEngine()
    private var started = false

    private init() {
        configureSession()
    }

    private func configureSession() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private var enabled: Bool { GameSettings.shared.soundEnabled }

    func playFlap() {
        playTone(freq: 520, duration: 0.05, volume: 0.15)
    }

    func playPass() {
        playTone(freq: 880, duration: 0.04, volume: 0.1)
    }

    func playChime() {
        playTone(freq: 1200, duration: 0.08, volume: 0.12)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.playTone(freq: 1500, duration: 0.08, volume: 0.1)
        }
    }

    func playThud() {
        playTone(freq: 120, duration: 0.12, volume: 0.2)
    }

    private func playTone(freq: Double, duration: Double, volume: Float) {
        guard enabled else { return }
        ensureEngine()

        let sampleRate = 44_100.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        else { return }

        buffer.frameLength = frameCount
        let channels = buffer.floatChannelData![0]
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let attack = min(1.0, t * 80)
            let release = min(1.0, (duration - t) * 40)
            let env = Float(attack * release)
            channels[frame] = env * volume * sin(Float(2.0 * .pi * freq * t))
        }

        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        player.scheduleBuffer(buffer, at: nil, options: .interrupts) {
            DispatchQueue.main.async {
                player.stop()
                self.engine.detach(player)
            }
        }
        player.play()
    }

    private func ensureEngine() {
        guard !started else { return }
        do {
            try engine.start()
            started = true
        } catch {
            started = false
        }
    }
}
