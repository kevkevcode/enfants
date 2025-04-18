import Foundation

class Config {
    static let shared = Config()
    
    // Configuration de l'API OpenAI
    static let openAIAPIKey: String = {
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return apiKey
        }
        return "" // La clé sera fournie via les variables d'environnement
    }()
    
    // Configuration de l'API ElevenLabs
    static let elevenLabsAPIKey: String = {
        if let apiKey = ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] {
            return apiKey
        }
        return "" // La clé sera fournie via les variables d'environnement
    }()
    
    // URLs des APIs
    static let openAIAPIURL = "https://api.openai.com/v1/chat/completions"
    static let elevenLabsAPIURL = "https://api.elevenlabs.io/v1/text-to-speech"
    
    // Configuration du modèle
    static let openAIModel = "gpt-4"
    static let temperature = 0.7
    static let maxTokens = 1000
    
    private init() {}
    
    static func initialize() {
        _ = shared
        print("⚙️ Configuration initialisée")
    }
} 