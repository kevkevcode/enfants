import Foundation
import AVFoundation

class ComptineViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var histoire: String?
    @Published var titre: String?
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

    func genererHistoire(prenom: String, age: Int, passions: String, morale: String, longueur: StoryLength) {
        isLoading = true
        error = nil
        histoire = nil
        titre = nil
        
        ChatGPTService.shared.genererComptine(
            prenom: prenom,
            age: age,
            passions: passions,
            morale: morale,
            longueur: longueur
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let (titre, histoire)):
                    self?.histoire = histoire
                    self?.titre = titre
                    self?.error = nil
                    
                    // Sauvegarder l'histoire dans le profil
                    let enfants = EnfantService.chargerEnfants()
                    if var enfant = enfants.first(where: { $0.prenom == prenom }) {
                        let nouvelleHistoire = Histoire(titre: titre, contenu: histoire)
                        enfant.histoires.append(nouvelleHistoire)
                        EnfantService.sauvegarderEnfant(enfant)
                    }
                    
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
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
            elevenLabs.stopAudio()
            isPlaying = false
        } else if let audioData = audioData {
            elevenLabs.playAudio(audioData)
            isPlaying = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 