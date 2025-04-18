import SwiftUI
import AVFoundation

struct ComptineView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ComptineViewModel()
    @StateObject private var localization = LocalizationManager.shared
    @State private var showingHistorique = false
    @State private var showingStoryOptions = false
    @State private var selectedLength: StoryLength = .medium
    @State private var message: String = ""
    @State private var isSharing = false
    
    let prenom: String
    let age: Int
    let passions: String
    
    var body: some View {
        ZStack {
            Color.backgroundLight.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    if viewModel.isLoading {
                        LoadingHistoireView()
                    } else if let error = viewModel.error {
                        ErrorHistoireView(error: error) {
                            showingStoryOptions = true
                        }
                    } else if let histoire = viewModel.histoire {
                        HistoireContentView(
                            prenom: prenom,
                            histoire: histoire,
                            titre: viewModel.titre ?? localization.localizedString("story.title"),
                            regenerer: {
                                showingStoryOptions = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingHistorique = true }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.primaryPurple)
                }
            }
        }
        .sheet(isPresented: $showingHistorique) {
            HistoriqueView(prenom: prenom, selectedHistoire: $viewModel.histoire, selectedTitre: $viewModel.titre)
        }
        .sheet(isPresented: $showingStoryOptions) {
            StoryOptionsView(
                selectedLength: $selectedLength,
                message: $message,
                onGenerate: {
                    viewModel.genererHistoire(
                        prenom: prenom,
                        age: age,
                        passions: passions,
                        morale: message,
                        longueur: selectedLength
                    )
                }
            )
        }
        .onAppear {
            if let enfant = EnfantService.chargerEnfants().first(where: { $0.prenom == prenom }) {
                if let derniereHistoire = enfant.histoires.last {
                    viewModel.histoire = derniereHistoire.contenu
                    viewModel.titre = derniereHistoire.titre
                } else {
                    showingStoryOptions = true
                }
            }
        }
    }
}

struct StoryOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localization = LocalizationManager.shared
    @Binding var selectedLength: StoryLength
    @Binding var message: String
    let onGenerate: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(localization.localizedString("story.length.title"))) {
                    ForEach(StoryLength.allCases, id: \.self) { length in
                        Button(action: { selectedLength = length }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(length.title)
                                        .foregroundColor(.primary)
                                    Text("\(length.wordCount) \(localization.localizedString("story.length.words"))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedLength == length {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.primaryPurple)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text(localization.localizedString("story.message.title"))) {
                    // Boutons de valeurs prédéfinies
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(localization.currentLanguage == "fr" ? [
                                "L'entraide", "La bienveillance", "Le partage", "Le respect", 
                                "La persévérance", "L'amitié", "La politesse", "La confiance en soi"
                            ] : localization.currentLanguage == "en" ? [
                                "Helping others", "Kindness", "Sharing", "Respect",
                                "Perseverance", "Friendship", "Politeness", "Self-confidence"
                            ] : localization.currentLanguage == "es" ? [
                                "La ayuda mutua", "La amabilidad", "Compartir", "El respeto",
                                "La perseverancia", "La amistad", "La cortesía", "La confianza en sí mismo"
                            ] : [
                                "Взаимопомощь", "Доброта", "Совместное использование", "Уважение",
                                "Настойчивость", "Дружба", "Вежливость", "Уверенность в себе"
                            ], id: \.self) { valeur in
                                Button(action: {
                                    if message.contains(valeur) {
                                        message = message.replacingOccurrences(of: valeur + ", ", with: "")
                                        message = message.replacingOccurrences(of: ", " + valeur, with: "")
                                        message = message.replacingOccurrences(of: valeur, with: "")
                                    } else {
                                        if !message.isEmpty {
                                            message += ", "
                                        }
                                        message += valeur
                                    }
                                }) {
                                    Text(valeur)
                                        .font(.system(.subheadline, design: .rounded))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(message.contains(valeur) ? Color.primaryPurple : Color.primaryPurple.opacity(0.1))
                                        )
                                        .foregroundColor(message.contains(valeur) ? .white : .primaryPurple)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Champ de message personnalisé
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $message)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        if message.isEmpty {
                            Text(localization.localizedString("story.message.placeholder"))
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                    }
                }
            }
            .navigationTitle(localization.localizedString("story.options.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.localizedString("story.options.cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localizedString("story.options.generate")) {
                        onGenerate()
                        dismiss()
                    }
                    .disabled(message.isEmpty)
                }
            }
        }
    }
}

struct HistoriqueView: View {
    let prenom: String
    @Binding var selectedHistoire: String?
    @Binding var selectedTitre: String?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if let enfant = EnfantService.chargerEnfants().first(where: { $0.prenom == prenom }) {
                        ForEach(enfant.histoires.sorted(by: { $0.date > $1.date })) { histoire in
                            Button(action: {
                                selectedHistoire = histoire.contenu
                                selectedTitre = histoire.titre
                                dismiss()
                            }) {
                                VStack(alignment: .leading, spacing: 16) {
                                    // En-tête avec titre et date
                                    HStack {
                                        Image(systemName: "book.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(Color.primaryPurple)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(histoire.titre)
                                                .font(.system(.title3, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundColor(.primaryPurple)
                                            
                                            Text(formatDate(histoire.date))
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.secondaryBlue)
                                        }
                                    }
                                    
                                    // Aperçu de l'histoire
                                    Text(histoire.contenu.prefix(150) + "...")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.textPrimary)
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                        .padding(.vertical, 8)
                                    
                                    // Indicateur de sélection
                                    HStack {
                                        Spacer()
                                        Text(localization.localizedString("story.select"))
                                            .font(.system(.footnote, design: .rounded))
                                            .foregroundColor(.secondaryBlue)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondaryBlue)
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.cardBackground)
                                        .shadow(
                                            color: Color.primaryPurple.opacity(0.1),
                                            radius: 15,
                                            x: 0,
                                            y: 5
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color.backgroundLight.ignoresSafeArea())
            .navigationTitle("\(localization.localizedString("story.history")) \(prenom)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localizedString("settings.done")) {
                        dismiss()
                    }
                    .foregroundColor(.primaryPurple)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage == "fr" ? "fr_FR" : 
                                                LocalizationManager.shared.currentLanguage == "en" ? "en_US" :
                                                LocalizationManager.shared.currentLanguage == "es" ? "es_ES" : "ru_RU")
        return formatter.string(from: date)
    }
}

// Vue de chargement animée
struct LoadingHistoireView: View {
    @State private var isAnimating = false
    @State private var dots = ""
    @State private var rotationAngle = 0.0
    @StateObject private var localization = LocalizationManager.shared
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                // Cercles animés avec transition plus douce
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0.2 : 0.6)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.4),
                            value: isAnimating
                        )
                }
                
                // Étoiles qui tournent avec transition plus douce
                ForEach(0..<5) { index in
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primaryPurple)
                        .offset(x: isAnimating ? 50 : 0)
                        .rotationEffect(.degrees(Double(index) * 72))
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(
                            Animation.linear(duration: 4)
                                .repeatForever(autoreverses: false),
                            value: rotationAngle
                        )
                }
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 40))
                    .foregroundColor(.primaryPurple)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(
                        Animation.linear(duration: 4)
                            .repeatForever(autoreverses: false),
                        value: rotationAngle
                    )
            }
            
            Text(localization.localizedString("form.generating"))
                .font(.system(.title3, design: .rounded))
                .foregroundColor(.textSecondary)
        }
        .onAppear {
            isAnimating = true
            // Animation continue et fluide
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
        .onReceive(timer) { _ in
            if dots.count >= 3 {
                dots = ""
            } else {
                dots += "."
            }
        }
    }
}

// Vue d'erreur
struct ErrorHistoireView: View {
    let error: String
    let retry: () -> Void
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 30))
                    .foregroundColor(.red)
            }
            
            Text(localization.localizedString("alert.error.title"))
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(error)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: retry) {
                HStack {
                    Text(localization.localizedString("alert.retry"))
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.medium)
                    Image(systemName: "arrow.clockwise")
                }
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
    }
}

// Vue de l'histoire
struct HistoireContentView: View {
    let prenom: String
    let histoire: String
    let titre: String
    let regenerer: () -> Void
    @State private var isSharing = false
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var audioViewModel = AudioViewModel()
    
    var body: some View {
        VStack(spacing: 25) {
            // En-tête
            VStack(spacing: 15) {
                Text(titre)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primaryPurple)
                    .multilineTextAlignment(.center)
                
                Text(localization.localizedString("story.unique"))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.textSecondary)
            }
            
            // Contenu de l'histoire
            Text(histoire)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.textPrimary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cardBackground)
                        .shadow(color: Color.primaryPurple.opacity(0.1), radius: 10)
                )
            
            // Boutons d'action
            HStack(spacing: 15) {
                // Bouton de lecture audio
                Button(action: {
                    if audioViewModel.isPlaying {
                        audioViewModel.toggleAudio()
                    } else if audioViewModel.audioData != nil {
                        audioViewModel.toggleAudio()
                    } else {
                        audioViewModel.genererAudio(histoire: histoire)
                    }
                }) {
                    HStack {
                        Image(systemName: audioViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 20))
                        Text(audioViewModel.isPlaying ? localization.localizedString("story.pause") : localization.localizedString("story.play"))
                            .font(.system(.subheadline, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(audioViewModel.isGeneratingAudio ? Color.gray : Color.primaryPurple)
                    )
                    .foregroundColor(.white)
                }
                .disabled(audioViewModel.isGeneratingAudio)
                
                // Bouton de régénération
                Button(action: regenerer) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 20))
                        Text(localization.localizedString("story.new"))
                            .font(.system(.subheadline, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondaryBlue)
                    )
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            if audioViewModel.isGeneratingAudio {
                HStack(spacing: 10) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryPurple))
                    Text(localization.localizedString("story.generating.audio"))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
            }
            
            // Contrôles audio - ne s'affichent que si l'audio est disponible et pas en cours de génération
            if audioViewModel.audioData != nil && !audioViewModel.isGeneratingAudio {
                AudioControlView(viewModel: audioViewModel)
                    .padding()
            }
            
            Spacer()
            
            HStack {
                // Bouton de partage
                Button(action: {
                    isSharing = true
                }) {
                    Text(localization.localizedString("story.share"))
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.primaryPurple)
                                .shadow(color: Color.primaryPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .sheet(isPresented: $isSharing) {
                    ShareSheet(items: [histoire])
                }
            }
            .padding()
        }
        .padding()
    }
}

// Vue pour le partage
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ComptineView(
        prenom: "Lucas",
        age: 5,
        passions: "les sports et les amis"
    )
} 