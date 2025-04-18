import Foundation
import AVFoundation
import UIKit

class ElevenLabsService: NSObject, AVAudioPlayerDelegate {
    static let shared = ElevenLabsService()
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    
    // Notifications pour l'interface utilisateur
    static let audioProgressNotification = Notification.Name("AudioProgressUpdated")
    static let audioStateChangedNotification = Notification.Name("AudioStateChanged")
    
    // État de la lecture
    private(set) var isPlaying = false {
        didSet {
            NotificationCenter.default.post(
                name: ElevenLabsService.audioStateChangedNotification,
                object: nil,
                userInfo: ["isPlaying": isPlaying]
            )
        }
    }
    
    var hasActivePlayer: Bool {
        return player != nil
    }
    
    // Configuration
    private let apiKey = "sk_e63e024adde2fd45c8f8082dfc1af5123c8d97872db78b44"
    private let baseURL = "https://api.elevenlabs.io/v1"
    // Antoine - voix française naturelle de haute qualité
    private let voiceID = "XrExE9yKIg1WjnnlVkGX"
    
    // Options de voix optimisées pour une narration naturelle en français
    private let voiceSettings: [String: Any] = [
        "stability": 0.25,         // Très faible stabilité pour un maximum de naturel
        "similarity_boost": 1.0,   // Fidélité maximale à la voix originale
        "style": 0.85,            // Style expressif mais naturel
        "use_speaker_boost": true, // Améliore la clarté
        "speaking_rate": 0.90     // Rythme légèrement plus lent pour une narration claire
    ]
    
    override private init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try audioSession.setActive(true)
            print("Session audio configurée avec succès")
        } catch {
            print("Erreur de configuration de la session audio: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Contrôles de lecture
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seekToPercentage(_ percentage: Double) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let seekTime = totalSeconds * percentage
        seekToSeconds(seekTime)
    }
    
    func seekToSeconds(_ seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time)
    }
    
    func skipForward() {
        seekBySeconds(10)
    }
    
    func skipBackward() {
        seekBySeconds(-10)
    }
    
    private func seekBySeconds(_ seconds: Double) {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTimeGetSeconds(currentTime) + seconds
        seekToSeconds(newTime)
    }
    
    func generateSpeech(from text: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let endpoint = "\(baseURL)/text-to-speech/\(voiceID)"
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "ElevenLabsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL invalide"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_multilingual_v2",  // Modèle optimisé pour le français
            "voice_settings": voiceSettings,
            "optimize_streaming_latency": 0
        ]
        
        // Debug logs
        print("URL: \(url)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("API Key utilisée: \(apiKey)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("Body: \(bodyString)")
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "ElevenLabsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Réponse invalide"])))
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            print("Response headers: \(httpResponse.allHeaderFields)")
            if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "ElevenLabsService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Erreur serveur: \(httpResponse.statusCode)"])))
                return
            }
            
            guard let audioData = data else {
                completion(.failure(NSError(domain: "ElevenLabsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Données audio manquantes"])))
                return
            }
            
            print("Données audio reçues: \(audioData.count) octets")
            
            // Vérifier que les données commencent par l'en-tête MP3
            let mp3Header: [UInt8] = [0x49, 0x44, 0x33] // "ID3"
            let dataPrefix = Array(audioData.prefix(3))
            print("En-tête des données: \(dataPrefix.map { String(format: "%02X", $0) }.joined())")
            
            DispatchQueue.main.async {
                self.playAudio(audioData)
            }
            
            completion(.success(audioData))
        }.resume()
    }
    
    func playAudio(_ audioData: Data) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Si le lecteur existe déjà et contient les mêmes données, on reprend juste la lecture
            if let currentPlayer = self.player,
               let currentItem = currentPlayer.currentItem,
               let currentURL = (currentItem.asset as? AVURLAsset)?.url,
               currentURL.lastPathComponent == "temp_audio.mp3" {
                self.play()
                return
            }
            
            // Sinon, on crée un nouveau lecteur
            self.stopAudio()
            
            do {
                let audioFileURL = self.getDocumentsDirectory().appendingPathComponent("temp_audio.mp3")
                try audioData.write(to: audioFileURL)
                
                let playerItem = AVPlayerItem(url: audioFileURL)
                self.player = AVPlayer(playerItem: playerItem)
                
                // Observer pour la progression
                self.removeTimeObserver()
                self.addTimeObserver()
                
                // Observer pour la fin de la lecture
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.playerDidFinishPlaying),
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: playerItem
                )
                
                self.play()
            } catch {
                print("Erreur de lecture: \(error)")
            }
        }
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player?.currentItem?.duration,
                  duration.isValid,
                  !duration.isIndefinite else { return }
            
            let currentTime = CMTimeGetSeconds(time)
            let totalDuration = CMTimeGetSeconds(duration)
            let progress = currentTime / totalDuration
            
            NotificationCenter.default.post(
                name: ElevenLabsService.audioProgressNotification,
                object: nil,
                userInfo: [
                    "progress": progress,
                    "currentTime": currentTime,
                    "duration": totalDuration
                ]
            )
        }
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        isPlaying = false
        seekToSeconds(0)
    }
    
    func stopAudio() {
        removeTimeObserver()
        player?.pause()
        player = nil
        isPlaying = false
    }
    
    // AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Lecture audio terminée - Succès: \(flag)")
        stopAudio()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Erreur de décodage audio: \(error)")
        }
        stopAudio()
    }
} 