import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Fond coloré et joyeux
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Titre de l'application
                    Text("Comptines Magiques")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                        .shadow(radius: 2)
                    
                    // Image ou illustration
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 100))
                        .foregroundColor(.purple)
                        .padding()
                    
                    // Bouton pour créer une comptine
                    NavigationLink(destination: FormView()) {
                        Text("Créer une comptine")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.purple)
                                    .shadow(radius: 5)
                            )
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
} 