import Foundation

enum Config {
    static let openAIAPIURL = "https://api.openai.com/v1/chat/completions"
    static var openAIAPIKey = ""
    static let elevenLabsAPIURL = "https://api.elevenlabs.io/v1"
    static var elevenLabsAPIKey = ""
    static let session = URLSession.shared
} 