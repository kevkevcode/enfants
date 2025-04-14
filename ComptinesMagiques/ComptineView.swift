import SwiftUI
import AVFoundation

struct ComptineView: View {
    let prenom: String
    let activite: String
    let morale: String
    
    @State private var comptine: String = ""
    @State private var isPlaying = false
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            // Fond coloré
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Titre
                    Text("Ta comptine magique")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                        .padding(.top, 20)
                    
                    // Illustration
                    Image(systemName: "book.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.purple)
                        .padding()
                    
                    // Texte de la comptine
                    Text(comptine)
                        .font(.system(.body, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                                .shadow(radius: 5)
                        )
                        .padding()
                    
                    // Bouton de lecture
                    Button(action: {
                        if isPlaying {
                            synthesizer.stopSpeaking(at: .immediate)
                        } else {
                            let utterance = AVSpeechUtterance(string: comptine)
                            utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
                            utterance.rate = 0.5
                            utterance.pitchMultiplier = 1.2
                            synthesizer.speak(utterance)
                        }
                        isPlaying.toggle()
                    }) {
                        HStack {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            Text(isPlaying ? "Arrêter" : "Écouter")
                        }
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.purple)
                                .shadow(radius: 5)
                        )
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Génération de la comptine à l'apparition de la vue
            let generator = ComptineGenerator()
            comptine = generator.genererComptine(prenom: prenom, activite: activite, morale: morale)
        }
    }
}

#Preview {
    ComptineView(prenom: "Emma", activite: "joué au parc", morale: "la persévérance")
} 