import Foundation
import SwiftUI

// ViewModel pour gérer l'état des enfants
class EnfantViewModel: ObservableObject {
    // État des enfants
    @Published var enfants: [Enfant] = []
    @Published var selectedEnfant: Enfant?
    
    // État de chargement
    @Published var isLoading = false
    
    // Initialisation
    init() {
        // Charger les données des enfants au démarrage
        chargerEnfants()
    }
    
    // Charger les données des enfants
    func chargerEnfants() {
        isLoading = true
        // Simuler un délai pour éviter les problèmes d'interface
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.enfants = EnfantService.chargerEnfants()
            self.isLoading = false
        }
    }
    
    // Sauvegarder les données d'un enfant
    func sauvegarderEnfant(prenom: String, age: Int, activite: String, passions: String, photo: Data? = nil) {
        let nouvelEnfant = Enfant(
            id: UUID(),
            prenom: prenom,
            age: age,
            activite: activite,
            passions: passions,
            photo: photo,
            histoires: []
        )
        EnfantService.sauvegarderEnfant(nouvelEnfant)
        chargerEnfants()
    }
    
    // Mettre à jour les données d'un enfant
    func mettreAJourEnfant(id: UUID, prenom: String, age: Int, activite: String, passions: String, photo: Data? = nil) {
        let enfantMisAJour = Enfant(
            id: id,
            prenom: prenom,
            age: age,
            activite: activite,
            passions: passions,
            photo: photo,
            histoires: enfants.first(where: { $0.id == id })?.histoires ?? []
        )
        EnfantService.sauvegarderEnfant(enfantMisAJour)
        chargerEnfants()
    }
    
    // Supprimer un enfant
    func supprimerEnfant(id: UUID) {
        EnfantService.supprimerEnfant(id)
        chargerEnfants()
    }
    
    // Sélectionner un enfant
    func selectionnerEnfant(_ enfant: Enfant) {
        selectedEnfant = enfant
    }
    
    func creerEnfant(prenom: String, age: Int, activite: String, passions: String, photo: Data?) {
        let nouvelEnfant = Enfant(
            prenom: prenom,
            age: age,
            activite: activite,
            passions: passions,
            photo: photo
        )
        
        EnfantService.sauvegarderEnfant(nouvelEnfant)
        chargerEnfants()
    }
} 