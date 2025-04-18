import Foundation
import AVFoundation

class AudioViewModel: ObservableObject {
    @Published var isGeneratingAudio = false
    @Published var audioData: Data?
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    
    private let elevenLabs = ElevenLabsService.shared
    
    init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlaybackProgress),
            name: ElevenLabsService.audioProgressNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlaybackStateChange),
            name: ElevenLabsService.audioStateChangedNotification,
            object: nil
        )
    }
    
    @objc private func handlePlaybackProgress(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let progress = userInfo["progress"] as? Double,
           let currentTime = userInfo["currentTime"] as? Double,
           let duration = userInfo["duration"] as? Double {
            DispatchQueue.main.async {
                self.progress = progress
                self.currentTime = currentTime
                self.duration = duration
            }
        }
    }
    
    @objc private func handlePlaybackStateChange(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let isPlaying = userInfo["isPlaying"] as? Bool {
            DispatchQueue.main.async {
                self.isPlaying = isPlaying
            }
        }
    }
    
    func genererAudio(histoire: String) {
        guard audioData == nil else {
            toggleAudio()
            return
        }
        
        isGeneratingAudio = true
        isPlaying = false
        
        elevenLabs.generateSpeech(from: histoire) { [weak self] result in
            DispatchQueue.main.async {
                self?.isGeneratingAudio = false
                
                switch result {
                case .success(let audioData):
                    self?.audioData = audioData
                    self?.toggleAudio()
                case .failure(let error):
                    print("Erreur de génération audio: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func toggleAudio() {
        if isPlaying {
            ElevenLabsService.shared.pause()
            isPlaying = false
        } else {
            if let audioData = audioData {
                if ElevenLabsService.shared.hasActivePlayer {
                    ElevenLabsService.shared.play()
                    isPlaying = true
                } else {
                    ElevenLabsService.shared.playAudio(audioData)
                    isPlaying = true
                }
            } else {
                print("❌ Pas de données audio disponibles")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 