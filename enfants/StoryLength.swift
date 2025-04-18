import Foundation

enum StoryLength: String, CaseIterable {
    case short
    case medium
    case long
    
    var title: String {
        switch self {
        case .short: return LocalizationManager.shared.localizedString("story.length.short")
        case .medium: return LocalizationManager.shared.localizedString("story.length.medium")
        case .long: return LocalizationManager.shared.localizedString("story.length.long")
        }
    }
    
    var wordCount: Int {
        switch self {
        case .short: return 150
        case .medium: return 300
        case .long: return 500
        }
    }
} 