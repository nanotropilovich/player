import AVFoundation
import SwiftUI
import Combine

class AudioPlayer: NSObject, ObservableObject {
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var isSeeking = false

    @Published var isPlaying = false
    @Published var duration: TimeInterval?
    private var atTime: TimeInterval = 0
    @Published var currentTime: TimeInterval?
    func setPlaybackRate(_ rate: Double) {
           guard let player = player else { return }

        
               player.rate = Float(rate)
           
       }
    override init() {
        super.init()
           configureAudioSession()
           
       }

      private func configureAudioSession() {
          do {
              try AVAudioSession.sharedInstance().setCategory(.playback)
              try AVAudioSession.sharedInstance().setActive(true)
          } catch {
              print("Setting up the audio session failed.")
          }
      }
    func playAudio(from url: URL, startTime: TimeInterval = 0,_ rate: Double = 1) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.enableRate = true
            player?.rate = Float(rate)
            player?.prepareToPlay()
            player?.currentTime = startTime
            player?.play()
            duration = player?.duration
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                guard let self = self, !self.isSeeking else { return }
                self.currentTime = self.player?.currentTime
            })

            isPlaying = true
           
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }


    func stopPlaying(at time: TimeInterval? = nil) {
        if let time = time {
            self.currentTime = time
            self.player?.currentTime = time
        }
        self.player?.stop()
        self.timer?.invalidate()
        self.timer = nil
        self.isPlaying = false
    }


    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }
    
    
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaying()
    }
    
}
