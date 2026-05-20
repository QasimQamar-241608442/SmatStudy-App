📚 SmartStudy AI – Timetable & Learning Assistant
A smart academic planning Android application built with Flutter and Firebase, designed to help university students organize their study schedules, manage courses, and generate AI-powered learning content.

🎯 Overview
SmartStudy AI solves a common problem for university students: the lack of intelligent, structured tools for academic planning. Students can upload course outlines, get AI-generated study notes and schedules, track deadlines, and manage their academic workload — all in one place.
Target Audience: University students, college students, and self-learners.

✨ Features
Core Features

🔐 User Authentication – Email/password login with Firebase Auth and session persistence
🗄️ Database Integration – Local storage (SQLite/Hive) + Firestore with full CRUD and offline sync
🌐 RESTful API Integration – External AI API for study notes and schedule generation
🖥️ UI & Navigation – 7+ screens with Material Design 3 and Google Fonts (Inter)
📷 Media Handling – Camera/gallery access, file uploads, Firebase Storage
🔍 Search & Filter – Real-time global search with multiple filters and sort options
⚠️ Error Handling & Validation – Form validation, network error handling, and Firebase error management
⚙️ Settings & User Preferences – Profile management, account settings, and persistent preferences

Advanced Features

🤖 AI-Powered Notes – Generate structured study notes from course outlines via AI API
📅 Smart Planner – Automated timetable and daily schedule generation
🔔 Push Notifications – Deadline and study reminders
📊 Grades & Analytics – Track academic performance and study progress


🖼️ App Screens
#ScreenDescription1Splash ScreenApp launch and initialization2Login / RegistrationAuthentication with Firebase3Home DashboardToday's tasks, upcoming deadlines, study hours4Courses ManagementAdd, edit, and organize courses and semesters5Study PlannerAI-generated weekly study schedule6Daily TimetableDay-by-day task and time management7AI Notes ScreenAI-generated notes from course outlines8Global AI ScreenGeneral AI-powered study assistant9Grades ScreenTrack grades and academic performance10NotificationsManage reminders and alerts11Global SearchSearch across courses, tasks, and notes12Profile & SettingsUser profile, account settings, preferences

🛠️ Tech Stack
LayerTechnologyFrameworkFlutter (Dart)AuthenticationFirebase AuthenticationCloud DatabaseFirebase FirestoreLocal StorageSQLite / HiveFile StorageFirebase StorageAI IntegrationExternal AI REST APIUI StylingMaterial Design 3, Google Fonts (Inter)State ManagementFlutter built-in (StatefulWidget)

📁 Project Structure
lib/
├── main.dart                        # App entry point & Firebase initialization
├── firebase_options.dart            # Firebase platform configuration
├── core/
│   └── theme/
│       └── app_theme.dart           # Global app theme (Material 3)
└── features/
    ├── auth/                        # Login, registration, auth wrapper
    ├── splash/                      # Splash screen
    ├── dashboard/                   # Home dashboard, courses view, semesters
    ├── home/                        # Main home screen
    ├── courses/                     # Course & task management
    ├── planner/                     # Daily timetable & global task planner
    ├── ai/                          # AI notes & global AI assistant
    ├── grades/                      # Grades tracking
    ├── notifications/               # Push notifications
    ├── search/                      # Global search
    └── profile/                     # Profile, settings, account management

🚀 Getting Started
Prerequisites

Flutter SDK (3.x or higher)
Dart SDK
Android Studio or VS Code with Flutter extension
A Firebase project (see setup below)

Installation

Clone the repository

bash   git clone https://github.com/QasimQamar-241608442/SmatStudy-App.git
   cd SmatStudy-App

Install dependencies

bash   flutter pub get

Firebase Setup

Create a project at Firebase Console
Enable Authentication (Email/Password)
Enable Firestore Database
Enable Firebase Storage
Download and replace google-services.json (Android) in android/app/
Run flutterfire configure to regenerate lib/firebase_options.dart


Configure AI API

Obtain an API key from your AI provider
Add the key to your environment/config file (do not commit API keys)


Run the app

bash   flutter run

🔧 Environment Configuration

⚠️ Never commit API keys or Firebase credentials to version control.

Create a .env file or use Flutter's --dart-define for sensitive values:
bashflutter run --dart-define=AI_API_KEY=your_key_here
Add the following to .gitignore:
google-services.json
*.env
lib/firebase_options.dart

📦 Key Dependencies
yamldependencies:
  flutter:
  firebase_core:
  firebase_auth:
  cloud_firestore:
  firebase_storage:
  google_fonts:
  # Add remaining packages from pubspec.yaml

🤝 Contributing
This project is currently an academic submission. For any suggestions or feedback, feel free to open an issue on the repository.

👤 Author
Qasim Qamar
Student ID: 241-608442
GitHub: @QasimQamar-241608442

📄 License
This project is developed for academic purposes. All rights reserved © 2026 Qasim Qamar.
