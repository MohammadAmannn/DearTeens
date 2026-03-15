# Hello Teen

Hello Teen is a safe and educational platform designed for teenagers (ages 13–19) where they can learn about puberty, menstruation, mental health, hygiene, and body changes without embarrassment.

## Features
* **Anonymous AI Assistant**: Ask questions safely powered by Gemini.
* **Education Hub**: Learn about Puberty, Menstrual Health, and Hygiene.
* **Period Tracker**: Keep track of cycles and symptoms securely (for girls).
* **Mental Health Check-In**: Log daily moods and view trends.
* **Myth vs Fact**: Educational swipe cards.

## Setup Instructions

### 1. Flutter Setup
Ensure you have the latest stable version of Flutter installed.
```bash
flutter doctor
flutter pub get
```

### 2. Environment Variables (.env)
A `.env` file is required at the root of the project to securely manage the API keys. 
1. Open the project folder.
2. Locate the `.env` file (if you cannot see it, ensure hidden files are visible or create it at the root).
3. Paste your credentials exactly in this format:

```env
GEMINI_API_KEY=PASTE_YOUR_GEMINI_API_KEY_HERE
FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY
FIREBASE_APP_ID=YOUR_FIREBASE_APP_ID
FIREBASE_PROJECT_ID=YOUR_FIREBASE_PROJECT_ID
FIREBASE_MESSAGING_SENDER_ID=YOUR_FIREBASE_SENDER_ID
FIREBASE_STORAGE_BUCKET=YOUR_FIREBASE_STORAGE_BUCKET
```

### 3. Firebase Setup
This project uses Firebase for Auth, Firestore, and Analytics. You need to configure your environment to match your Firebase project.

1. Install the FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```
2. Run the configuration command in the root `hello_teen/` directory:
```bash
flutterfire configure --project="your-firebase-project-id"
```
3. Uncomment the Firebase initialization block in `lib/main.dart`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 4. Running the App
Once standard configuration is complete, you can start the application:
```bash
flutter run
```

### 5. Building Release APK (Play Store Ready)
To generate a release build for Android:
```bash
flutter build apk --release
```
For generating App Bundles (preferred for Play Store):
```bash
flutter build appbundle --release
```

Ensure standard signing configuration is applied inside `android/app/build.gradle`.
