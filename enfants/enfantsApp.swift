//
//  enfantsApp.swift
//  enfants
//
//  Created by Kevin Verd on 03.04.2025.
//

import SwiftUI

@main
struct enfantsApp: App {
    @StateObject private var preferences = UserPreferences.shared
    
    init() {
        // Initialisation des services
        Config.initialize()
        ChatGPTService.setup()
        print("🚀 Application démarrée")
    }
    
    var body: some Scene {
        WindowGroup {
            if !preferences.hasSelectedLanguage {
                LanguageSelectionView(
                    selectedLanguage: $preferences.selectedLanguage,
                    hasSelectedLanguage: $preferences.hasSelectedLanguage
                )
            } else {
                ContentView()
            }
        }
    }
}
