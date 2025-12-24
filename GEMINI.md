# Statveil

## Project Overview

Statveil is a Flutter-based mobile application that gamifies productivity. It's inspired by the web novel "Solo Leveling" and incorporates features like stats, quests, experience points (EXP), streaks, and daily penalties. The app is designed to motivate users to complete their daily tasks by rewarding them with in-game progress.

## Building and Running

To build and run the project, you'll need to have the Flutter SDK installed.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/statveil.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd statveil
    ```
3.  **Install the dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Development Conventions

*   **Code Style:** The project follows the official Dart style guide.
*   **Linting:** The project uses the `flutter_lints` package to enforce good coding practices.
*   **File Structure:** The code is organized into features, models, services, and core utilities.
*   **UI:** The UI is built using the Material Design library.

## Key Files

*   `lib/main.dart`: The main entry point of the application.
*   `lib/features/dashboard/dashboard_screen.dart`: The main screen of the application, which displays the user's stats, quests, and progress.
*   `lib/models/hunter.dart`: The data model for the user's character.
*   `lib/features/quests/quest_model.dart`: The data model for the quests.
*   `lib/features/quests/quest_service.dart`: The service that provides the daily quests.
*   `lib/services/exp_service.dart`: The service that calculates the experience points awarded for completing a quest.
*   `lib/core/utils/daily_reset.dart`: The utility that handles the daily reset of the app's state.
