# ALU Academic Assistant - Group 13

A mobile app built with Flutter that helps ALU students stay on top of their academics. You can manage assignments, schedule sessions, and track your attendance all in one place.

## What the app does

- **Dashboard** shows your current academic week, today's sessions, upcoming assignments, attendance percentage, and warns you if attendance drops below 75%
- **Assignments** lets you create, edit, delete, and mark assignments as done with priority levels (High, Medium, Low)
- **Schedule** shows your weekly calendar where you can add sessions, browse different weeks, and mark yourself as present or absent

## How to run it

Make sure you have Flutter installed on your machine. If not, follow the official guide at https://docs.flutter.dev/get-started/install

1. Clone the repo
```
git clone https://github.com/hasby-umutoniwabo/alu-academic-assistant_Grp13.git
cd alu-academic-assistant_Grp13
```

2. Generate the project files (android, ios, etc)
```
flutter create .
```

3. Install dependencies
```
flutter pub get
```

4. Open an Android emulator from Android Studio (Tools > Device Manager > Launch)

5. Run the app
```
flutter run
```

The app should launch on the emulator.

## Project structure

```
lib/
  main.dart              - App entry point, navigation, data persistence
  models/
    assignment.dart      - Assignment data model
    session.dart         - Session data model
  screens/
    dashboard_screen.dart    - Home screen with stats and overview
    assignments_screen.dart  - Assignment management
    schedule_screen.dart     - Weekly schedule and attendance
  utils/
    constants.dart       - ALU colors and app theme
```

## Data storage

We used shared_preferences to save data locally on the device. Assignments and sessions are converted to JSON and stored so they persist between app restarts.

## Team members

- **Hasbiyallah** - Data models, theme, constants, git setup
- **Jesse** - Dashboard screen
- **Shem Ayioka** - Assignments screen
- **Grevy** - Schedule screen
- **Kyla** - Main app integration, persistence

## Built with

- Flutter 3.x
- Dart
- shared_preferences package
