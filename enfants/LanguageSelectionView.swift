import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: String
    @Binding var hasSelectedLanguage: Bool
    @StateObject private var localization = LocalizationManager.shared
    
    let languages = [
        ("🇫🇷 Français", "fr"),
        ("🇬🇧 English", "en"),
        ("🇪🇸 Español", "es"),
        ("🇷🇺 Русский", "ru")
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "globe")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Choisissez votre langue")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose your language")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                VStack(spacing: 15) {
                    ForEach(languages, id: \.1) { language in
                        Button(action: {
                            selectedLanguage = language.1
                            localization.currentLanguage = language.1
                            UserPreferences.shared.selectedLanguage = language.1
                            hasSelectedLanguage = true
                        }) {
                            HStack {
                                Text(language.0)
                                    .font(.title3)
                                
                                Spacer()
                                
                                if selectedLanguage == language.1 {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedLanguage == language.1 ? Color.blue.opacity(0.1) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedLanguage == language.1 ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    LanguageSelectionView(
        selectedLanguage: .constant("fr"),
        hasSelectedLanguage: .constant(false)
    )
} 