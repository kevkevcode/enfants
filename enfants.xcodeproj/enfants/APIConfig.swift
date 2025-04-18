import Foundation

enum APIConfig {
    static let openAIURL = "https://api.openai.com/v1/chat/completions"
    static var openAIKey = ""
    static let elevenLabsURL = "https://api.elevenlabs.io/v1"
    static var elevenLabsKey = ""
    static let networkSession = URLSession.shared
    
    static func isValidOpenAIKey() -> Bool {
        return !openAIKey.isEmpty
    }
    
    static func isValidElevenLabsKey() -> Bool {
        return !elevenLabsKey.isEmpty
    }
    
    static var isConfigured: Bool {
        return isValidOpenAIKey() && isValidElevenLabsKey()
    }
} 