# Statveil

A Solo-Leveling-inspired productivity gamification app built with Flutter. Track your daily quests, gain experience, level up your character, and maintain streaks—all while completing real-world tasks.

## Features

- **Character Stats**: Track and improve your STR, INT, AGI, VIT, and WILL attributes
- **Daily Quests**: Complete assigned quests to gain experience and level up
- **Experience System**: Earn EXP based on quest difficulty (Easy: 10, Medium: 25, Hard: 50, Boss: 100)
- **Leveling**: Progress through levels as you gain experience
- **Streak System**: Maintain consecutive days of completed quests for motivation
- **Daily Reset**: Automatic daily reset with penalties for missed quests
- **Cross-Platform**: Runs on Windows, macOS, Linux, iOS, Android, and Web

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

4. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

- `lib/main.dart` - Application entry point
- `lib/features/dashboard/` - Main dashboard UI
- `lib/features/quests/` - Quest models and services
- `lib/models/hunter.dart` - Character data model
- `lib/services/` - Business logic services
- `lib/core/utils/` - Utility functions

## Development Conventions

- **Code Style**: Follows the official Dart style guide
- **Linting**: Uses `flutter_lints` package for code quality
- **Architecture**: Organized into features, models, services, and core utilities
- **UI Framework**: Material Design 3

## License

MIT License - See [LICENSE](LICENSE) file for details

## Author

Shreyash Meshram
