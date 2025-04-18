import Foundation

class Config {
    static let shared = Config()
    
    // API Keys
    let openAIKey: String
    let elevenLabsKey: String
    
    // API URLs
    let openAIURL = "https://api.openai.com/v1/chat/completions"
    let elevenLabsURL = "https://api.elevenlabs.io/v1/text-to-speech"
    
    private init() {
        // Les clés sont chargées depuis les variables d'environnement
        // Pour configurer votre projet, créez un fichier .env avec :
        // OPENAI_API_KEY=votre_clé_openai
        // ELEVENLABS_API_KEY=votre_clé_elevenlabs
        openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        elevenLabsKey = ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] ?? ""
    }
    
    func testConnection() async throws {
        // Vérifie la connexion aux APIs
        // Cette fonction est utilisée pour valider la configuration
        // lors du démarrage de l'application
    }
} 