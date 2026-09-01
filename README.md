# Disaster Survival Guide

Offline-first emergency assistance app for quick access to first aid guidance, emergency kit preparation, safe-route navigation, and SOS actions when internet or normal communications are unavailable.

This project is built with Flutter and stores emergency data locally in SQLite so it works even when the device is offline. The app uses a dark, high-contrast interface designed for stressful, low-light situations, with large touch targets and a simple emergency triage layout.

## Features

- First aid guides for common emergencies:
  - Bleeding
  - Burns
  - Choking
  - Broken bones
  - CPR
  - Shock
- Survival kit builder with progress tracking and persistent saved state
- GPS-based safe-zone navigation with live distance and directional guidance
- Survival tips sheet for water, shelter, warming, and general emergency advice
- SOS emergency action with SMS draft and location attachment
- Offline operation with local database and no internet dependency
- Dark mode UI optimized for battery-saving and emergency readability

## Tech Stack

- Flutter + Dart
- Provider for state management
- SQLite via sqflite for local data persistence
- geolocator for location and distance calculations
- url_launcher for SMS intent support
- audioplayers for siren/alert audio
- torch_light for flashlight SOS pattern support
- shared_preferences for lightweight local settings
- permission_handler for runtime permissions

## Project Structure

- lib/main.dart — app entry point and app setup
- lib/core/database/database_helper.dart — SQLite schema and seed data
- lib/core/providers — state providers for first aid, kit builder, and compass
- lib/core/services/sos_service.dart — emergency SOS and GPS logic
- lib/core/theme/app_theme.dart — theme and app colors
- lib/features/ — screens for home, first aid, survival kit, and compass navigation
- assets/ — images, audio, data, and fonts
- android/ , ios/ , windows/ — platform target folders

## Prerequisites

Before running this app, install:

- Flutter SDK 3.4.0 or newer
- Android Studio or VS Code with Flutter extension
- An emulator or physical device
- Git for version control

Check your environment:

```bash
flutter doctor
```

## Getting Started

1. Clone the repository:

```bash
git clone <repository-url>
cdf disaster_survival_guide
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

4. For Android release build:

```bash
flutter build apk
```

5. For App Bundle:

```bash
flutter build appbundle
```

## How to Use the App

### 1. Home Screen

The home screen acts as the main emergency dashboard. It includes four main actions:

- First Aid
- Survival Kit
- Safe Route
- Survival Tips

There is also a persistent SOS control near the bottom of the screen that can be held to trigger an emergency SMS.

### 2. First Aid

Tap the First Aid card to open the emergency response section.

- Select a condition such as Bleeding or CPR
- Review the step-by-step visual instructions
- Use the guidance in order during an emergency

The content is pre-seeded into SQLite and loaded at runtime.

### 3. Survival Kit Builder

Tap the Survival Kit card to build a checklist.

- Check items you already packed
- Categories include water, food, medical supplies, tools, shelter, and documents
- Progress is calculated live as a percentage
- Use Reset All to clear the checklist if needed

### 4. Safe Route / Compass

Tap the Safe Route card to open the compass navigation screen.

- Allow location permission when prompted
- Select a safe zone target from the list
- The arrow rotates to point toward the selected safe zone
- Distance is updated in real time based on GPS

> Safe zones are seeded with sample coordinates and should be replaced with real local emergency locations before deployment in a real-world environment.

### 5. SOS Button

Hold the SOS button for about 1.5 seconds.

- The app fetches the current GPS position if permission is available
- It builds an SMS message with location and timestamp
- It opens the device SMS app so the emergency message can be sent

The default emergency number in the code is set to 112. This can be customized in the SOS logic if needed.

## Emergency Notes and Safety Advice

- This app is designed as a quick-reference emergency tool and should not replace official emergency services.
- For professional medical assistance, always contact local emergency responders.
- GPS and SMS behavior depend on device permissions and platform support.
- The safe zone list is sample data and should be replaced with trusted local emergency location data before production use.

## App Behavior and Offline Design

The app is intentionally built to work without network access:

- SQLite stores emergency instructions and emergency kit data locally
- The app does not require a server connection for base functionality
- GPS and SMS launch are used only when device permissions are available
- The app keeps a simple dark-mode UI to reduce distractions during emergencies

## Configuration and Customization

### Update emergency contact

The default SOS number is defined in:

- lib/core/services/sos_service.dart

You can change the default contact or store a user-defined contact in SharedPreferences as the app grows.

### Replace safe zone data

The default safe zone entries are seeded in:

- lib/core/database/database_helper.dart

Update the safe_zones list to match local shelters, hospitals, water points, or evacuation centers in your region.

### Add more first aid content

Emergency categories and steps are stored in the same database helper file. If you want to expand the app with new first aid conditions, update the category seed list and instruction steps there.

## Common Commands

```bash
flutter clean
flutter pub get
flutter run
flutter test
flutter build apk
```

## Platform Notes

- Android: full support for GPS, SMS launching, flashlight, and local SQLite data
- iOS: supported with the same Flutter app structure, subject to platform permission behavior
- Windows/macOS/Linux: desktop support is included for development, but GPS and SMS features depend on OS-level support and permissions

## License

This project is currently intended for personal or internal development use unless a specific license is added later.

## Summary

Disaster Survival Guide is a compact offline emergency app that helps users act quickly during a crisis. It brings together first aid instructions, survival preparation tracking, route guidance to safe zones, and SOS communication in one fast-access interface.
