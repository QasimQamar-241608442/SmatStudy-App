markdown_content = """
# SmartStudy 📚

> Elevate your academic workflow.

SmartStudy is a premium, fully-functional Flutter application designed specifically for students. It acts as a comprehensive academic planner, combining traditional course and task management with real-time syncing, intelligent search, and synthesized AI study insights.

## ✨ Key Features

* **Secure Authentication:** Includes traditional Email/Password login, seamless Google Sign-In (OAuth 2.0), password reset functionality, and complete account data deletion capabilities.
* **The Academic Core:** Build your academic timeline. Add and manage Semesters, nested Courses, and specific Tasks or Assignments. 
* **Global Smart Search:** A real-time, cross-category search engine. Filter by Courses, Deadlines, Files, or Professors instantly. Includes a dynamic "Zero-State" dashboard showcasing recent activity and urgent deadlines.
* **Intelligent Notifications:** No static alerts here. The Smart Synthesis Engine dynamically reads your Firestore data to alert you of urgent deadlines (with countdowns), newly posted materials, simulated grade releases, and AI-driven study pattern insights.
* **Dynamic Profile Management:** Track your overall GPA and completed credits. Edit your specific degree program on the fly, synced directly to your cloud profile.

## 🛠 Tech Stack

* **Frontend:** [Flutter](https://flutter.dev/) (Dart)
* **Backend / Database:** [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore)
* **Authentication:** [Firebase Authentication](https://firebase.google.com/docs/auth) & [Google Sign-In](https://pub.dev/packages/google_sign_in)
* **Architecture:** Feature-first directory structure with StreamBuilder for real-time reactive UI.

## 📱 Screen Flow & Architecture

1.  **Auth Module (`/auth`)**
    * `LoginScreen`: Email/password and Google login. Handles 3-strike failed attempt logic revealing a password reset flow.
    * `RegistrationScreen`: User creation with automated Firestore document initialization.
2.  **Dashboard & Core (`/dashboard`, `/courses`)**
    * `SemestersView`: The academic journey hub. Real-time list of semesters with secure, context-aware deletion menus.
    * (Includes underlying screens for Courses and Task management).
3.  **Discovery (`/search`, `/notifications`)**
    * `GlobalSearchScreen`: The central search engine with interactive filtering chips and dynamic empty states.
    * `NotificationsScreen`: Activity feed synthesizing Firestore deadlines and creation timestamps into actionable alerts.
4.  **Profile (`/profile`)**
    * `ProfileScreen`: User identity, dynamic degree editing via dialogs, and top-level settings routing.
    * `AccountSettingsScreen`: Data management hub featuring secure multi-step account deletion.

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.0.0+)
* A Firebase Project with Authentication (Email/Password & Google) and Firestore enabled.

### Installation

1.  **Clone the repository:**
    ```
```text?code_stdout&code_event_index=2
README.md generated successfully.

```bash
    git clone [https://github.com/yourusername/smartstudy.git](https://github.com/yourusername/smartstudy.git)
    cd smart_study
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase:**
    * Ensure your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are placed in their respective directories.
    * Enable Google Sign-In in your Firebase Authentication console.

### Web Development Configuration
Because this application uses Google Sign-In, running it on the web requires a static port to comply with Google's OAuth 2.0 authorized JavaScript origins.

1. Obtain your **Web Client ID** from the Google Cloud Console (APIs & Services > Credentials).
2. Add `http://localhost:5000` to your Authorized JavaScript origins.
3. Update the `clientId` in `login_screen.dart` and `registration_screen.dart`.
4. **Run the app on port 5000:**
   
   *Via Terminal:*
   ```bash
   flutter run -d chrome --web-port=5000

Via VS Code (.vscode/launch.json):

JSON
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "SmartStudy (Chrome Port 5000)",
            "request": "launch",
            "type": "dart",
            "toolArgs": ["--web-port=5000"]
        }
    ]
}

📄 License
This project is licensed under the MIT License.
"""
