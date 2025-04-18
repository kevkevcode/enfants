//
//  ContentView.swift
//  enfants
//
//  Created by Kevin Verd on 03.04.2025.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var enfants: [Enfant] = []
    @Published var isLoading = false
    
    init() {
        chargerEnfants()
    }
    
    func chargerEnfants() {
        enfants = EnfantService.chargerEnfants()
    }
    
    func supprimerEnfant(id: UUID) {
        EnfantService.supprimerEnfant(id)
        chargerEnfants()
    }
}

// Vue principale
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showingSettings = false
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundLight.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if viewModel.enfants.isEmpty {
                        // Vue vide avec bouton de création
                        VStack(spacing: 25) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.primaryPurple)
                            
                            Text(localization.localizedString("welcome.message"))
                                .font(.system(.title2, design: .rounded))
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            NavigationLink(destination: FormView(viewModel: viewModel)) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text(localization.localizedString("form.button"))
                                }
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.primaryPurple)
                                        .shadow(color: Color.primaryPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                                )
                            }
                        }
                        .padding()
                    } else {
                        // TabView pour les profils existants
                        TabView {
                            ForEach(viewModel.enfants) { enfant in
                                VStack {
                                    EnfantCard(enfant: enfant, viewModel: viewModel)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(height: 500)
                        
                        // Bouton pour ajouter un nouveau profil
                        NavigationLink(destination: FormView(viewModel: viewModel)) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(localization.localizedString("form.button"))
                            }
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.primaryPurple)
                                    .shadow(color: Color.primaryPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(localization.localizedString("story.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primaryPurple)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct EnfantCard: View {
    let enfant: Enfant
    let viewModel: ContentViewModel
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Photo de profil
            if let imageData = enfant.photo, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primaryPurple, lineWidth: 3))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.primaryPurple)
            }
            
            // Informations de l'enfant
            VStack(spacing: 10) {
                Text(enfant.prenom)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                NavigationLink(
                    destination: ComptineView(
                        prenom: enfant.prenom,
                        age: enfant.age,
                        passions: enfant.passions
                    )
                ) {
                    Text(localization.localizedString("content.generate"))
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primaryPurple)
                        )
                }
                
                NavigationLink(
                    destination: FormView(viewModel: viewModel, enfantToEdit: enfant)
                ) {
                    Text(localization.localizedString("content.edit"))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.primaryPurple)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primaryPurple, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardBackground)
                .shadow(color: Color.primaryPurple.opacity(0.1), radius: 10)
        )
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var photoData: Data? = nil
    
    var body: some View {
        HStack(spacing: 15) {
            if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primaryPurple.opacity(0.2), lineWidth: 1))
            } else {
                ZStack {
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.primaryPurple)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.primaryPurple.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

struct ActionButtonView: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
            
            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(color)
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .foregroundColor(.white)
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0.2 : 0.6)
                        .animation(
                            Animation.easeInOut(duration: 1)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 30))
                    .foregroundColor(.primaryPurple)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 2)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            Text(localization.localizedString("form.generating"))
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.textSecondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localization = LocalizationManager.shared
    let languages = [
        ("🇫🇷 Français", "fr"),
        ("🇬🇧 English", "en"),
        ("🇪🇸 Español", "es"),
        ("🇷🇺 Русский", "ru")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(languages, id: \.1) { language in
                        Button(action: {
                            UserPreferences.shared.selectedLanguage = language.1
                            localization.currentLanguage = language.1
                        }) {
                            HStack {
                                Text(language.0)
                                    .foregroundColor(.primary)
                                Spacer()
                                if localization.currentLanguage == language.1 {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.primaryPurple)
                                }
                            }
                        }
                    }
                } header: {
                    Text(localization.localizedString("settings.language"))
                }
            }
            .navigationTitle(localization.localizedString("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localizedString("settings.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
