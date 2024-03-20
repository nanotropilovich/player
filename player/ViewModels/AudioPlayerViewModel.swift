//
//  AudioPlayerViewModel.swift
//  player
//
//  Created by Ilya on 01.03.2024.
//

import Foundation
import Combine
class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var duration: TimeInterval? = nil
    @Published var currentTime: TimeInterval? = nil
    private var audioPlayer: AudioPlayer = AudioPlayer()
    private var disposables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }
    
    func setupBindings() {
        audioPlayer.$isPlaying
            .assign(to: \.isPlaying, on: self)
            .store(in: &disposables)
        
        audioPlayer.$currentTime
            .assign(to: \.currentTime, on: self)
            .store(in: &disposables)
        
        audioPlayer.$duration
            .assign(to: \.duration, on: self)
            .store(in: &disposables)
    }

    func playAudio(from url: URL) {
        audioPlayer.playAudio(from: url, startTime: currentTime ?? 0, 1.0)
    }
    
    func stopPlaying() {
        audioPlayer.stopPlaying()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer.seek(to: time)
    }
}
