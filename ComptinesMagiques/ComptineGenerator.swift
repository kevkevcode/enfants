import Foundation

class ComptineGenerator {
    // Templates de début de comptines
    private let debuts = [
        "Il était une fois %@,",
        "Voici l'histoire de %@,",
        "Par une belle journée,",
        "Dans un monde enchanté,",
        "Au pays des rêves dorés,"
    ]
    
    // Templates de fin de comptines
    private let fins = [
        "Et c'est ainsi que %@ apprit %@,",
        "Depuis ce jour, %@ comprit %@,",
        "Et %@ retint bien %@,",
        "C'est ainsi que %@ découvrit %@,"
    ]
    
    // Templates de morales
    private let morales = [
        "que %@ est important dans la vie",
        "que %@ rend plus heureux",
        "que %@ est une belle valeur",
        "que %@ est la clé du bonheur"
    ]
    
    func genererComptine(prenom: String, activite: String, morale: String) -> String {
        // Sélection aléatoire des templates
        let debut = debuts.randomElement()!
        let fin = fins.randomElement()!
        let moraleTemplate = morales.randomElement()!
        
        // Construction de la comptine
        var comptine = ""
        
        // Première strophe
        comptine += String(format: debut, prenom) + "\n"
        comptine += "Qui aujourd'hui a " + activite + ",\n"
        
        // Deuxième strophe
        comptine += "A fait preuve de courage,\n"
        comptine += "Et a montré son bel âge.\n\n"
        
        // Troisième strophe
        comptine += String(format: fin, prenom, String(format: moraleTemplate, morale)) + "\n"
        comptine += "Pour grandir et s'épanouir,\n"
        comptine += "Et toujours mieux réussir !"
        
        return comptine
    }
} 