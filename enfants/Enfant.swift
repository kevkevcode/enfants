import Foundation

// Structure représentant un enfant avec ses informations
struct Enfant: Codable, Identifiable {
    let id: UUID
    var prenom: String
    var age: Int
    var activite: String
    var passions: String
    var photo: Data?
    var histoires: [Histoire]
    
    init(id: UUID = UUID(), prenom: String, age: Int, activite: String, passions: String, photo: Data? = nil, histoires: [Histoire] = []) {
        self.id = id
        self.prenom = prenom
        self.age = age
        self.activite = activite
        self.passions = passions
        self.photo = photo
        self.histoires = histoires
    }
    
    // Vérifie si l'enfant a des données valides
    var estValide: Bool {
        return !prenom.isEmpty && age > 0 && !activite.isEmpty && !passions.isEmpty
    }
}

struct Histoire: Codable, Identifiable {
    let id: UUID
    let titre: String
    let contenu: String
    let date: Date
    
    init(id: UUID = UUID(), titre: String, contenu: String, date: Date = Date()) {
        self.id = id
        self.titre = titre
        self.contenu = contenu
        self.date = date
    }
}

// Service de gestion de la persistance des données
class EnfantService {
    // Clé pour stocker les données dans UserDefaults
    private static let enfantsKey = "enfantsData"
    
    // Sauvegarde les données de l'enfant
    static func sauvegarderEnfant(_ enfant: Enfant) {
        var enfants = chargerEnfants()
        if let index = enfants.firstIndex(where: { $0.id == enfant.id }) {
            enfants[index] = enfant
        } else {
            enfants.append(enfant)
        }
        if let encoded = try? JSONEncoder().encode(enfants) {
            UserDefaults.standard.set(encoded, forKey: enfantsKey)
            print("Enfant sauvegardé: \(enfant.prenom)")
        }
    }
    
    // Récupère tous les enfants
    static func chargerEnfants() -> [Enfant] {
        if let savedEnfants = UserDefaults.standard.data(forKey: enfantsKey),
           let loadedEnfants = try? JSONDecoder().decode([Enfant].self, from: savedEnfants) {
            print("Enfants chargés: \(loadedEnfants.count)")
            return loadedEnfants
        }
        return []
    }
    
    // Supprime un enfant spécifique
    static func supprimerEnfant(_ id: UUID) {
        var enfants = chargerEnfants()
        enfants.removeAll(where: { $0.id == id })
        if let encoded = try? JSONEncoder().encode(enfants) {
            UserDefaults.standard.set(encoded, forKey: enfantsKey)
            print("Enfant supprimé")
        }
    }
} 