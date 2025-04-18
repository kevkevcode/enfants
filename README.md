# Comptines Magiques

Une application iOS pour générer des comptines personnalisées pour les enfants.

## Fonctionnalités

- Création de comptines personnalisées basées sur le prénom, l'activité, les passions et la morale
- Sauvegarde du profil de l'enfant
- Lecture audio des comptines
- Génération via l'API ChatGPT ou localement

## Configuration

Pour utiliser l'application, vous devez configurer les clés API suivantes :

1. Créez un fichier `.env` à la racine du projet avec les variables suivantes :
   ```
   OPENAI_API_KEY=votre_clé_openai
   ELEVENLABS_API_KEY=votre_clé_elevenlabs
   ```

2. Assurez-vous que le fichier `.env` est bien ignoré par Git (il devrait l'être par défaut)

3. Copiez le fichier `Config.example.swift` en `Config.swift` et personnalisez-le selon vos besoins

### Obtention des clés API

- **OpenAI API** : Créez un compte sur [OpenAI](https://platform.openai.com/) et générez une clé API
- **ElevenLabs API** : Créez un compte sur [ElevenLabs](https://elevenlabs.io/) et générez une clé API

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

## GitHub Configuration

### Setting up Secrets

1. Go to your GitHub repository settings
2. Navigate to "Secrets and variables" > "Actions"
3. Add the following secrets:
   - `OPENAI_API_KEY`: Your OpenAI API key
   - `ELEVENLABS_API_KEY`: Your ElevenLabs API key

### Workflow Configuration

The repository includes two GitHub Actions workflows:

1. **CI/CD Pipeline** (`ci.yml`):
   - Runs on push to main and pull requests
   - Builds and tests the iOS app
   - Ensures code quality and functionality

2. **Secrets Management** (`secrets.yml`):
   - Manages API keys and sensitive configuration
   - Updates Config.swift with the latest secrets
   - Can be triggered manually for different environments

### Security Best Practices

- Never commit API keys directly in the code
- Use GitHub Secrets for storing sensitive information
- Keep the `.env` file in `.gitignore`
- Use `Config.example.swift` as a template for configuration
- Regularly rotate API keys and update secrets 