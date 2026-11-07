# Statveil

A Solo-Leveling-inspired productivity gamification app built with Flutter. Track your daily quests, gain experience, level up your character, and maintain streaks—all while completing real-world tasks.

## Features

- **Character Stats**: Track and improve your STR, INT, AGI, VIT, and WILL attributes, shown on the dashboard
- **Daily Quests**: Complete your daily quests to gain experience and level up
- **Custom Quests**: Add or delete your own quests, with any difficulty and the stat each one trains
- **Experience System**: Earn EXP based on quest difficulty (Easy: 10, Medium: 25, Hard: 50, Boss: 100)
- **Leveling**: Progress through levels as you gain experience
- **Streak System**: Maintain consecutive days of completed quests for motivation
- **Daily Reset**: Automatic reset at midnight with penalties for missed quests; each fully missed day costs a level
- **Cross-Platform**: Runs on Windows, macOS, iOS, Android, and Web

## Building and Running

To build and run the project, you'll need to have the Flutter SDK installed.

1. **Clone the repository:**

   ```bash
   git clone https://github.com/shreyuu/Statveil.git
   ```

2. **Navigate to the project directory:**

   ```bash
   cd statveil
   ```

3. **Install dependencies:**

   ```bash
   flutter pub get
   ```

4. **Configure Firebase** (see below), then **run the app:**
   ```bash
   flutter run
   ```

## Firebase setup

The Firebase config files (`lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `macos/Runner/GoogleService-Info.plist`) are gitignored, so a fresh clone won't build until you generate them:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=statveil
```

In the Firebase console, enable **Authentication → Sign-in method → Anonymous**. Then deploy the Firestore rules, which let each user read and write only their own `hunters/{uid}` document:

```bash
firebase deploy --only firestore:rules --project statveil
```

Restrict each API key in Google Cloud Console (APIs & Services → Credentials) to its platform (Android package, iOS bundle ID, web referrers) and to the Firebase APIs the app uses.

## Project Structure

- `lib/main.dart` - Application entry point
- `lib/features/dashboard/` - Main dashboard UI
- `lib/features/quests/` - Quest models and services
- `lib/models/hunter.dart` - Character data model
- `lib/services/` - Business logic services
- `lib/core/utils/` - Utility functions
- `firestore.rules` - Firestore security rules

## Development Conventions

- **Code Style**: Follows the official Dart style guide
- **Linting**: Uses `flutter_lints` package for code quality
- **Architecture**: Organized into features, models, services, and core utilities
- **UI Framework**: Material Design 3

## License

MIT License - See [LICENSE](LICENSE) file for details

## Author

Shreyash Meshram
