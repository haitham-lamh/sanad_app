# Sanad App 📱

![Sanad Application](assets/images/sanad.png)

Sanad is a comprehensive Flutter-based application designed to help users manage their daily tasks, deadlines, and notifications effectively. It integrates modern technologies like Firebase for backend services and Google's Gemini AI for intelligent assistance.

## 🚀 Features

- **Task Management**: Create, edit, and track tasks with deadlines.
- **Smart Assistance**: Powered by **Gemini AI** to help organize and suggest improvements for your schedule.
- **Push Notifications**: Stay updated with timely reminders using `flutter_local_notifications`.
- **Calendar Integration**: View and manage tasks in a calendar view.
- **Secure Authentication**: User sign-in and management via **Firebase Auth**.
- **Data Persistence**: Local storage support using `Hive` and `sqflite`.

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend/Services**: Firebase (Auth, Firestore, Storage)
- **AI Integration**: Google Gemini API
- **State Management**: GetX
- **Local Database**: Hive, SQFlite

## ⚙️ Setup & Installation

To run this project locally, follow these steps:

### 1. Clone the Repository
```bash
git clone https://github.com/haitham-lamh/sanad_app.git
cd sanad_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Sensitive Information
Because this project uses Firebase and Gemini API, you need to provide your own credentials.

#### **Firebase Configuration:**
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/).
2. Add Android/iOS apps to your project.
3. Download `google-services.json` (for Android) and place it in `android/app/`.
4. Download `GoogleService-Info.plist` (for iOS) and place it in `ios/Runner/`.
5. Rename `lib/firebase_options.example.dart` to `lib/firebase_options.dart`.
6. Update the file with your Firebase credentials (API Key, App ID, etc.) or run:
   ```bash
   flutterfire configure
   ```

#### **Gemini API Configuration:**
1. Get your API key from [Google AI Studio](https://aistudio.google.com/).
2. Rename `lib/config/gemini_config.example.dart` to `lib/config/gemini_config.dart`.
3. Open `lib/config/gemini_config.dart` and add your API key:
   ```dart
   const String kGeminiApiKey = 'YOUR_API_KEY_HERE';
   ```

### 4. Run the App
```bash
flutter run
```
