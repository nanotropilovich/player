import Foundation
import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
import UIKit
import Combine

struct URLDetailView: View {
    @State private var isSeeking = false
    let urls: [AudioFile]
    @State private var playbackSpeed: Double = 1.0
    let store: URLStore
    @State private var currentURLIndex: Int
    @State private var totalTime: TimeInterval = 0
    @State private var isPlaying = false
    @ObservedObject var audioPlayer = AudioPlayer()
    @State private var shouldReplay = false
    init( urls: [AudioFile],currentURLIndex: Int,store: URLStore) {
        self._currentURLIndex = State(initialValue: currentURLIndex)
        self.urls = urls
        self.store = store
    }
    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        let url = urls[currentURLIndex]
        let asset = AVURLAsset(url: url.url)
        VStack {
            Text(url.name)
            Text("\(formattedTime(url.currentTime)) / \(formattedTime(self.totalTime))")
            Slider(value: Binding(get: { url.currentTime }, set: { self.audioPlayer.seek(to: $0) }), in: 0...self.totalTime)
            
                .onReceive(self.audioPlayer.$currentTime) { currentTime in
                    
                    
                    url.currentTime = currentTime ?? 0
                    store.updateCurrentTime(for: url, to: currentTime ?? 0)
                }
                .onReceive(self.audioPlayer.$duration) { duration in
                    self.totalTime = duration ?? 0
                }
                .disabled(self.audioPlayer.duration == nil)
            Toggle("Replay Audio", isOn: $shouldReplay)
            Button(action: {
                withAnimation {
                   
                    if self.isPlaying {
                        self.audioPlayer.stopPlaying(at: url.currentTime)
                        self.isPlaying = false
                    } else {
                        if self.shouldReplay && (self.audioPlayer.currentTime ?? 0) >= self.totalTime {
                            self.audioPlayer.playAudio(from: url.url, startTime: 0, playbackSpeed)
                        } else {
                            self.audioPlayer.playAudio(from: url.url, startTime: url.currentTime, playbackSpeed)
                        }
                        self.isPlaying = true
                    }
                }
            }) {
                Image(systemName: self.isPlaying ? "stop.circle" : "play.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            
            
            HStack {
                Button(action: {
                    if currentURLIndex > 0 {
                        if audioPlayer.isPlaying {
                            audioPlayer.stopPlaying(at: url.currentTime)
                            isPlaying = false
                        }
                        currentURLIndex -= 1
                    }
                }) {
                    Image(systemName: "backward.end.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .disabled(currentURLIndex == 0)
                
                Spacer()
                
                Button(action: {
                    if currentURLIndex < urls.count - 1 {
                        if audioPlayer.isPlaying {
                            audioPlayer.stopPlaying(at: url.currentTime)
                            isPlaying = false
                        }
                        currentURLIndex += 1
                    }
                }) {
                    Image(systemName: "forward.end.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .disabled(currentURLIndex == urls.count - 1)
            }
            
            
        }
        .onReceive(self.audioPlayer.$currentTime) { currentTime in
            if let currentTime = currentTime {
                let playbackErrorMargin: TimeInterval = 1.0
                if currentTime >= (self.totalTime - playbackErrorMargin) {
                    if self.shouldReplay {
                        DispatchQueue.main.async {
                            self.audioPlayer.stopPlaying(at: 0)
                            self.isPlaying = false
                            self.audioPlayer.playAudio(from: url.url, startTime: 0, playbackSpeed)
                            self.isPlaying = true
                        }
                    } else {
                        self.isPlaying = false
                    }
                }
            }
        }
        
        
        .onDisappear {
            if audioPlayer.isPlaying {
                audioPlayer.stopPlaying(at: url.currentTime)
                isPlaying = false
            }
            
        }
        .frame(width: 300, height: 200)
        Slider(value: $playbackSpeed, in: 1...6, step: 0.1)
            .onChange(of: playbackSpeed) { newValue in
                audioPlayer.setPlaybackRate(newValue)
            }
            .frame(width: 200) 
        
        Text("Playback Speed: \(playbackSpeed, specifier: "%.1fx")")
            .padding()
    }
}
