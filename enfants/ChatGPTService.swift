import Foundation
import Network

// Structures pour décoder la réponse de l'API ChatGPT
struct ChatGPTResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// Service pour gérer les appels API à ChatGPT
class ChatGPTService: NSObject, URLSessionTaskDelegate {
    static let shared = ChatGPTService()
    
    // URL de l'API OpenAI
    private static let apiURL = URL(string: Config.openAIAPIURL)!
    
    // Configuration de la requête
    private static let maxRetries = 3
    private static let retryDelay: TimeInterval = 2.0
    private static var monitor: NWPathMonitor?
    private static var isNetworkAvailable = false
    private static var isAPIAvailable = false
    private static var pendingRequests: [(String, Int, String, String, StoryLength, (Result<(String, String), Error>) -> Void)] = []
    private var currentRetryCount = 0
    
    override private init() {
        super.init()
        Self.setupNetworkMonitoring()
    }
    
    private func testAPI(completion: @escaping (Bool) -> Void) {
        Self.testAPIConnection { success, _ in
            Self.isAPIAvailable = success
            completion(success)
        }
    }
    
    // Fonction pour générer une comptine
    func genererComptine(
        prenom: String,
        age: Int,
        passions: String,
        morale: String,
        longueur: StoryLength,
        completion: @escaping (Result<(String, String), Error>) -> Void
    ) {
        if !Self.isNetworkAvailable {
            print("📡 [DEBUG] Réseau indisponible, mise en file d'attente...")
            Self.pendingRequests.append((prenom, age, passions, morale, longueur, completion))
            return
        }
        
        if !Self.isAPIAvailable {
            print("🔄 [DEBUG] API indisponible, test en cours...")
            testAPI { [weak self] success in
                if success {
                    self?.genererComptine(prenom: prenom, age: age, passions: passions, morale: morale, longueur: longueur, completion: completion)
                } else {
                    Self.pendingRequests.append((prenom, age, passions, morale, longueur, completion))
                }
            }
            return
        }
        
        sendRequest(prenom: prenom, age: age, passions: passions, morale: morale, longueur: longueur, completion: completion)
    }
    
    private func sendRequest(prenom: String, age: Int, passions: String, morale: String, longueur: StoryLength, completion: @escaping (Result<(String, String), Error>) -> Void) {
        print("📡 [DEBUG] Préparation de la requête API...")
        print("📝 [DEBUG] Paramètres reçus:")
        print("   - Prénom: \(prenom)")
        print("   - Âge: \(age)")
        print("   - Passions: \(passions)")
        print("   - Morale: \(morale)")
        print("   - Longueur: \(longueur)")
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("❌ [DEBUG] URL invalide")
            completion(.failure(NSError(domain: "ChatGPTService", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL invalide"])))
            return
        }
        
        print("🔑 [DEBUG] Vérification de la clé API...")
        guard !Config.openAIAPIKey.isEmpty else {
            print("❌ [DEBUG] Clé API manquante")
            completion(.failure(NSError(domain: "ChatGPTService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Clé API manquante"])))
            return
        }
        
        print("📝 [DEBUG] Construction du prompt...")
        let language = LocalizationManager.shared.currentLanguage
        print("🌐 [DEBUG] Langue sélectionnée: \(language)")
        let languagePrompt: String
        switch language {
        case "fr":
            languagePrompt = "Tu es un conteur pour enfants expert en histoires courtes et amusantes en français. Adapte ton langage et la complexité de l'histoire pour un enfant de \(age) ans."
        case "en":
            languagePrompt = "You are a storyteller expert in short and fun children's stories in English. Adapt your language and story complexity for a \(age)-year-old child."
        case "es":
            languagePrompt = "Eres un cuentacuentos experto en historias cortas y divertidas para niños en español. Adapta tu lenguaje y la complejidad de la historia para un niño de \(age) años."
        case "ru":
            languagePrompt = "Вы рассказчик, специализирующийся на коротких и веселых детских историях на русском языке. Адаптируйте язык и сложность истории для ребенка \(age) лет."
        default:
            languagePrompt = "Tu es un conteur pour enfants expert en histoires courtes et amusantes en français. Adapte ton langage et la complexité de l'histoire pour un enfant de \(age) ans."
        }
        
        let prompt = """
        \(languagePrompt)
        
        \(language == "fr" ? """
        Génère une histoire \(longueur == .short ? "courte" : longueur == .medium ? "de longueur moyenne" : "longue") (environ \(longueur.wordCount) mots) et adaptée pour un enfant de \(age) ans avec les éléments suivants :
        - Prénom de l'enfant : \(prenom)
        - Centres d'intérêt : \(passions)
        - Morale de l'histoire : \(morale)
        
        Structure de l'histoire :
        1. Introduction : présente le personnage principal et son univers
        2. Milieu : introduit une complication ou un défi
        3. Fin : résout le problème de manière positive
        
        Réponds avec un titre court et accrocheur sur la première ligne, suivi d'un retour à la ligne, puis l'histoire.
        L'histoire doit être positive et encourageante.
        Utilise un vocabulaire et des concepts adaptés à l'âge de l'enfant.
        
        IMPORTANT : La morale doit être implicite dans l'histoire, transmise à travers les actions et les choix des personnages.
        Ne mentionne jamais explicitement la morale à la fin de l'histoire.
        Ne termine pas l'histoire en expliquant ce que l'enfant a appris.
        Laisse le lecteur tirer ses propres conclusions.
        """ : language == "en" ? """
        Generate a \(longueur == .short ? "short" : longueur == .medium ? "medium-length" : "long") story (about \(longueur.wordCount) words) adapted for a \(age)-year-old child with the following elements:
        - Child's name: \(prenom)
        - Interests: \(passions)
        - Story's moral: \(morale)
        
        Story structure:
        1. Introduction: introduce the main character and their world
        2. Middle: introduce a complication or challenge
        3. End: resolve the problem in a positive way
        
        Respond with a short catchy title on the first line, followed by a line break, then the story.
        The story should be positive and encouraging.
        Use vocabulary and concepts appropriate for the child's age.
        
        IMPORTANT: The moral should be implicit in the story, conveyed through the characters' actions and choices.
        Never explicitly state the moral at the end of the story.
        Do not end the story by explaining what the child learned.
        Let the reader draw their own conclusions.
        """ : language == "es" ? """
        Genera una historia \(longueur == .short ? "corta" : longueur == .medium ? "de longitud media" : "larga") (aproximadamente \(longueur.wordCount) palabras) adaptada para un niño de \(age) años con los siguientes elementos:
        - Nombre del niño: \(prenom)
        - Intereses: \(passions)
        - Moraleja de la historia: \(morale)
        
        Estructura de la historia:
        1. Introducción: presenta al personaje principal y su mundo
        2. Medio: introduce una complicación o desafío
        3. Final: resuelve el problema de manera positiva
        
        Responde con un título corto y atractivo en la primera línea, seguido de un salto de línea, luego la historia.
        La historia debe ser positiva y alentadora.
        Utiliza vocabulario y conceptos apropiados para la edad del niño.
        
        IMPORTANTE: La moraleja debe ser implícita en la historia, transmitida a través de las acciones y elecciones de los personajes.
        Nunca menciones explícitamente la moraleja al final de la historia.
        No termines la historia explicando lo que el niño aprendió.
        Deja que el lector saque sus propias conclusiones.
        """ : """
        Создайте \(longueur == .short ? "короткую" : longueur == .medium ? "среднюю" : "длинную") историю (примерно \(longueur.wordCount) слов), адаптированную для ребенка \(age) лет, со следующими элементами:
        - Имя ребенка: \(prenom)
        - Интересы: \(passions)
        - Мораль истории: \(morale)
        
        Структура истории:
        1. Введение: представьте главного героя и его мир
        2. Середина: введите осложнение или вызов
        3. Конец: решите проблему положительным образом
        
        Ответьте коротким привлекательным заголовком на первой строке, затем с новой строки напишите историю.
        История должна быть позитивной и вдохновляющей.
        Используйте словарный запас и понятия, соответствующие возрасту ребенка.
        
        ВАЖНО: Мораль должна быть неявной в истории, передаваемой через действия и выбор персонажей.
        Никогда не упоминайте мораль явно в конце истории.
        Не заканчивайте историю объяснением того, чему научился ребенок.
        Позвольте читателю сделать свои собственные выводы.
        """)
        """
        
        print("🛠 [DEBUG] Configuration de la requête...")
        
        // Configuration de la session URL
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        sessionConfig.waitsForConnectivity = true
        sessionConfig.allowsCellularAccess = true
        sessionConfig.allowsConstrainedNetworkAccess = true
        sessionConfig.allowsExpensiveNetworkAccess = true
        
        let session = URLSession(configuration: sessionConfig)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("enfants-app/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30.0
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": languagePrompt],
            ["role": "user", "content": prompt]
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 800,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0
        ]
        
        do {
            print("📦 [DEBUG] Encodage des paramètres...")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("❌ [DEBUG] Erreur d'encodage JSON: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("🚀 [DEBUG] Envoi de la requête à OpenAI...")
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [DEBUG] Erreur réseau: \(error.localizedDescription)")
                print("❌ [DEBUG] Détails de l'erreur: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [DEBUG] Réponse invalide")
                completion(.failure(NSError(domain: "ChatGPTService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Réponse invalide"])))
                return
            }
            
            print("📡 [DEBUG] Code de réponse HTTP: \(httpResponse.statusCode)")
            print("📡 [DEBUG] Headers de réponse: \(httpResponse.allHeaderFields)")
            
            guard let data = data else {
                print("❌ [DEBUG] Pas de données reçues")
                completion(.failure(NSError(domain: "ChatGPTService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Pas de données reçues"])))
                return
            }
            
            do {
                print("📦 [DEBUG] Décodage de la réponse...")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 [DEBUG] Réponse brute: \(responseString)")
                }
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(ChatGPTResponse.self, from: data)
                
                if let content = response.choices.first?.message.content {
                    let components = content.components(separatedBy: "\n\n")
                    let titre = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let histoire = components.dropFirst().joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    print("✅ [DEBUG] Histoire générée avec succès")
                    completion(.success((titre, histoire)))
                } else {
                    print("❌ [DEBUG] Contenu manquant dans la réponse")
                    completion(.failure(NSError(domain: "ChatGPTService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Contenu manquant dans la réponse"])))
                }
            } catch {
                print("❌ [DEBUG] Erreur de décodage: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
        print("📡 [DEBUG] Requête lancée, en attente de réponse...")
    }
    
    static func setup() {
        print("✅ ChatGPTService initialisé")
        print("📡 Surveillance réseau activée")
        
        // Vérification immédiate du réseau
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            checkNetworkStatus()
            
            // Vérification de la configuration
            print("🔑 Vérification de la configuration API")
            print("📝 URL de l'API configurée: \(Config.openAIAPIURL)")
            print("🔒 Clé API configurée: \(Config.isAPIKeyConfigured ? "Oui" : "Non")")
            if !Config.isAPIKeyConfigured {
                print("⚠️ La clé API n'est pas configurée correctement")
            }
        }
    }
    
    static func setupNetworkMonitoring() {
        print("🌐 [DEBUG] Configuration du monitoring réseau...")
        monitor = NWPathMonitor()
        
        monitor?.pathUpdateHandler = { path in
            isNetworkAvailable = path.status == .satisfied
            print("🌐 [DEBUG] État du réseau : \(isNetworkAvailable ? "Connecté" : "Déconnecté")")
            
            // Log des interfaces disponibles
            print("📡 [DEBUG] Interfaces réseau disponibles :")
            path.availableInterfaces.forEach { interface in
                print("   - Type: \(interface.type)")
            }
            
            // Vérification du type de connexion
            if path.usesInterfaceType(.cellular) {
                print("📱 [DEBUG] Connexion cellulaire détectée")
            }
            if path.usesInterfaceType(.wifi) {
                print("📶 [DEBUG] Connexion WiFi détectée")
            }
            
            // Log des conditions réseau
            print("📊 [DEBUG] Conditions réseau :")
            print("   - Connexion coûteuse : \(path.isExpensive)")
            print("   - Connexion contrainte : \(path.isConstrained)")
            
            if path.status != .satisfied {
                print("❌ [DEBUG] Conditions réseau non satisfaites")
                if path.unsatisfiedReason == .notAvailable {
                    print("   - Raison : Réseau non disponible")
                } else if path.unsatisfiedReason == .cellularDenied {
                    print("   - Raison : Accès cellulaire refusé")
                } else if path.unsatisfiedReason == .wifiDenied {
                    print("   - Raison : Accès WiFi refusé")
                } else if path.unsatisfiedReason == .localNetworkDenied {
                    print("   - Raison : Accès réseau local refusé")
                }
            }
            
            if isNetworkAvailable {
                handleNetworkChange()
            }
        }
        
        monitor?.start(queue: DispatchQueue.global())
        print("✅ [DEBUG] Monitoring réseau démarré")
        
        // Test immédiat de la connexion
        testAPIConnection { success, error in
            if success {
                print("✅ [DEBUG] Test de connexion initial réussi")
            } else {
                print("❌ [DEBUG] Test de connexion initial échoué : \(error ?? "Erreur inconnue")")
            }
        }
    }
    
    private static func handleNetworkChange() {
        if isNetworkAvailable {
            print("🌐 [DEBUG] Réseau disponible, traitement des requêtes en attente...")
            while let request = pendingRequests.first {
                pendingRequests.removeFirst()
                print("🔄 [DEBUG] Traitement de la requête en attente pour \(request.0)")
                shared.genererComptine(
                    prenom: request.0,
                    age: request.1,
                    passions: request.2,
                    morale: request.3,
                    longueur: request.4,
                    completion: request.5
                )
            }
        }
    }
    
    private static func testAPIConnection() {
        guard let url = URL(string: "\(Config.openAIAPIURL)/models") else {
            print("❌ URL de test invalide")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        
        print("🔄 Test de connexion à l'API OpenAI...")
        
        let task = Config.session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Erreur de test API: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Code de réponse test API: \(httpResponse.statusCode)")
                print("✅ API OpenAI accessible")
            }
        }
        task.resume()
    }
    
    // Fonction pour vérifier manuellement l'état du réseau
    static func checkNetworkStatus() {
        print("📡 Vérification manuelle du réseau")
        print("📱 État actuel: \(isNetworkAvailable ? "Connecté" : "Déconnecté")")
        if !isNetworkAvailable {
            print("⚠️ Le réseau n'est pas disponible")
            if let currentPath = monitor?.currentPath {
                print("📱 Interfaces disponibles: \(currentPath.availableInterfaces.map { String(describing: $0.type) }.joined(separator: ", "))")
            }
        }
    }
    
    static func testAPIConnection(completion: @escaping (Bool, String?) -> Void) {
        print("🔄 [DEBUG] Test de connexion à l'API OpenAI...")
        
        guard let url = URL(string: "https://api.openai.com/v1/models") else {
            print("❌ [DEBUG] URL invalide")
            completion(false, "URL invalide")
            return
        }
        
        print("🔑 [DEBUG] Vérification de la clé API...")
        guard !Config.openAIAPIKey.isEmpty else {
            print("❌ [DEBUG] Clé API manquante")
            completion(false, "Clé API manquante")
            return
        }
        
        print("🛠 [DEBUG] Configuration de la requête...")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("enfants-app/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10
        
        print("📡 [DEBUG] Envoi de la requête de test...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [DEBUG] Erreur de connexion: \(error.localizedDescription)")
                completion(false, "Erreur de connexion: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [DEBUG] Réponse invalide")
                completion(false, "Réponse invalide")
                return
            }
            
            print("📡 [DEBUG] Code de réponse: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200:
                print("✅ [DEBUG] Connexion à l'API réussie")
                completion(true, nil)
            case 401:
                print("❌ [DEBUG] Erreur d'authentification - Clé API invalide")
                completion(false, "Clé API invalide")
            case 403:
                print("❌ [DEBUG] Accès refusé")
                completion(false, "Accès refusé")
            case 429:
                print("⚠️ [DEBUG] Limite de requêtes atteinte")
                completion(false, "Limite de requêtes atteinte")
            default:
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("❌ [DEBUG] Erreur inattendue: \(str)")
                    completion(false, "Erreur inattendue: \(str)")
                } else {
                    print("❌ [DEBUG] Erreur inattendue: \(httpResponse.statusCode)")
                    completion(false, "Erreur inattendue: \(httpResponse.statusCode)")
                }
            }
        }
        task.resume()
        print("📡 [DEBUG] Requête lancée, en attente de réponse...")
    }
} 