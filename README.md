# Comptines Magiques

Une application iOS pour générer des comptines personnalisées pour les enfants.

## Fonctionnalités

- Création de comptines personnalisées basées sur le prénom, l'activité, les passions et la morale
- Sauvegarde du profil de l'enfant
- Lecture audio des comptines
- Génération via l'API ChatGPT ou localement

## Configuration de l'API OpenAI

Pour utiliser l'API ChatGPT, vous devez configurer votre clé API OpenAI :

1. Obtenez une clé API OpenAI sur [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Ouvrez le fichier `Config.swift` dans le projet
3. Remplacez la valeur de `openAIAPIKey` par votre clé API :

```swift
static let openAIAPIKey = "sk-votre-clé-api-réelle-ici"
```

4. Assurez-vous que la clé API est valide et a les permissions nécessaires

## Structure du projet

- `ContentView.swift` : Vue principale de l'application
- `FormView.swift` : Formulaire pour saisir les informations de l'enfant
- `ComptineView.swift` : Affichage et lecture de la comptine générée
- `ComptineGenerator.swift` : Générateur local de comptines
- `ChatGPTService.swift` : Service pour appeler l'API ChatGPT
- `Config.swift` : Configuration de l'application
- `Enfant.swift` : Modèle de données pour l'enfant
- `EnfantViewModel.swift` : ViewModel pour gérer l'état de l'enfant

## Comment ça marche

1. L'utilisateur saisit les informations de l'enfant dans le formulaire
2. L'application tente de générer une comptine via l'API ChatGPT
3. Si l'API échoue ou si la clé API n'est pas configurée, l'application utilise le générateur local
4. La comptine est affichée à l'utilisateur avec un indicateur de source (API ou locale)
5. L'utilisateur peut écouter la comptine en audio

## Dépannage

Si aucune comptine n'est générée par l'API :

1. Vérifiez que votre clé API est correctement configurée dans `Config.swift`
2. Vérifiez que vous avez une connexion Internet active
3. Consultez les logs dans la console Xcode pour identifier le problème
4. Si l'API échoue, l'application utilisera automatiquement le générateur local

## Remarques

- L'application nécessite une connexion Internet pour utiliser l'API ChatGPT
- Les données de l'enfant sont stockées localement sur l'appareil
- La génération locale est utilisée comme solution de secours si l'API échoue 