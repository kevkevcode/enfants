import SwiftUI

struct FormView: View {
    @State private var prenom: String = ""
    @State private var activite: String = ""
    @State private var morale: String = ""
    @State private var showingComptine = false
    
    var body: some View {
        ZStack {
            // Fond coloré
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Titre
                    Text("Créons ta comptine")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                        .padding(.top, 20)
                    
                    // Champs de formulaire
                    VStack(alignment: .leading, spacing: 20) {
                        // Champ prénom
                        VStack(alignment: .leading) {
                            Text("Le prénom de l'enfant")
                                .font(.headline)
                                .foregroundColor(.purple)
                            TextField("Ex: Emma", text: $prenom)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(.body, design: .rounded))
                        }
                        
                        // Champ activité
                        VStack(alignment: .leading) {
                            Text("Ce qu'il/elle a fait aujourd'hui")
                                .font(.headline)
                                .foregroundColor(.purple)
                            TextField("Ex: joué au parc", text: $activite)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(.body, design: .rounded))
                        }
                        
                        // Champ morale
                        VStack(alignment: .leading) {
                            Text("La morale à transmettre")
                                .font(.headline)
                                .foregroundColor(.purple)
                            TextField("Ex: la persévérance", text: $morale)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(.body, design: .rounded))
                        }
                    }
                    .padding()
                    
                    // Bouton de génération
                    Button(action: {
                        showingComptine = true
                    }) {
                        Text("Générer la comptine")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.purple)
                                    .shadow(radius: 5)
                            )
                    }
                    .padding(.horizontal)
                    .disabled(prenom.isEmpty || activite.isEmpty || morale.isEmpty)
                    .opacity(prenom.isEmpty || activite.isEmpty || morale.isEmpty ? 0.6 : 1)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showingComptine) {
            ComptineView(prenom: prenom, activite: activite, morale: morale)
        }
    }
}

#Preview {
    FormView()
} 