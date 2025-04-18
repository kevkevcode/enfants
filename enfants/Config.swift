import Foundation

// Configuration de l'application
struct Config {
    // Configuration de l'API OpenAI
    static let openAIAPIURL = "https://api.openai.com/v1/chat/completions"
    static let openAIModel = "gpt-4"
    static let temperature = 0.7
    static let maxTokens = 1000
    
    // Clés API - À configurer via les variables d'environnement
    static let openAIAPIKey: String = {
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return apiKey
        }
        return "" // La clé sera fournie via les variables d'environnement
    }()
    
    static let elevenLabsAPIKey: String = {
        if let apiKey = ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] {
            return apiKey
        }
        return "" // La clé sera fournie via les variables d'environnement
    }()
    
    // Configuration ElevenLabs
    static let elevenLabsAPIURL = "https://api.elevenlabs.io/v1/text-to-speech"
    static let elevenLabsVoiceID = "" // À configurer selon la voix souhaitée
    
    // Session URLSession dédiée
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        // Ajout des headers par défaut
        config.httpAdditionalHeaders = [
            "User-Agent": "enfants-app/1.0",
            "Accept-Language": "fr-FR",
            "Accept-Encoding": "gzip, deflate"
        ]
        
        return URLSession(configuration: config)
    }()
    
    // Vérification de la configuration
    static var isAPIKeyConfigured: Bool {
        let key = openAIAPIKey
        let isValid = !key.isEmpty && key.hasPrefix("sk-")
        print("🔑 Vérification de la clé API: \(isValid ? "Valide" : "Non valide")")
        return isValid
    }
    
    static func initialize() {
        print("⚙️ Configuration initialisée")
        print("🌐 URL API: \(openAIAPIURL)")
        print("📝 Modèle: \(openAIModel)")
        print("🔑 État de la clé API: \(isAPIKeyConfigured ? "Configurée" : "Non configurée")")
        
        // Test de connexion à l'API
        testAPIConnection()
    }
    
    static func testAPIConnection() {
        guard isAPIKeyConfigured else {
            print("❌ La clé API n'est pas configurée")
            return
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/models") else {
            print("❌ URL invalide")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("enfants-app/1.0", forHTTPHeaderField: "User-Agent")
        
        print("🔄 Test de connexion à l'API en cours...")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error as NSError? {
                print("❌ Erreur de connexion (\(error.code)): \(error.localizedDescription)")
                print("📝 Domaine de l'erreur: \(error.domain)")
                
                if error.code == -1009 {
                    print("📱 Pas de connexion Internet - Vérifiez votre connexion")
                } else if error.code == -1001 {
                    print("⏱ Délai d'attente dépassé - Essayez à nouveau")
                } else if error.code == -1200 {
                    print("🔒 Erreur SSL/TLS - Vérifiez votre connexion")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Réponse invalide du serveur")
                return
            }
            
            print("📡 Code de réponse: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200:
                print("✅ Connexion à l'API réussie")
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("📊 Réponse reçue: \(json)")
                }
            case 401:
                print("❌ Erreur d'authentification - Clé API invalide")
                print("🔍 Vérifiez votre clé sur: https://platform.openai.com/api-keys")
            case 403:
                print("❌ Accès refusé - Vérifiez les permissions de votre clé API")
                print("🔍 Vérifiez votre compte sur: https://platform.openai.com/account")
            case 429:
                print("⚠️ Limite de requêtes atteinte")
                print("🔍 Vérifiez votre utilisation sur: https://platform.openai.com/usage")
            default:
                print("❌ Erreur inattendue: \(httpResponse.statusCode)")
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("📝 Réponse du serveur: \(str)")
                }
            }
        }
        task.resume()
    }
} 
