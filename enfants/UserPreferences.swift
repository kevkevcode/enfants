import Foundation

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        }
    }
    
    @Published var hasSelectedLanguage: Bool {
        didSet {
            UserDefaults.standard.set(hasSelectedLanguage, forKey: "hasSelectedLanguage")
        }
    }
    
    private init() {
        self.selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "fr"
        self.hasSelectedLanguage = UserDefaults.standard.bool(forKey: "hasSelectedLanguage")
    }
} 