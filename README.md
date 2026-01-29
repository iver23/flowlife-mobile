# FlowLife Mobile 🚀

FlowLife is a premium task management and productivity application built with Flutter. It helps you capture thoughts, organize tasks into projects, and gain insights into your productivity with a beautiful, high-performance interface.

![FlowLife Banner](https://img.shields.io/badge/Flutter-3.10.7-blue.svg?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange.svg?style=for-the-badge&logo=firebase)
![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-blue?style=for-the-badge)

## ✨ Features

- **🎯 Smart Task Management**: Quick-capture tasks using natural language and organize them into specialized projects.
- **💡 Idea Capture**: A dedicated space for transient thoughts and creative sparks before they become actionable tasks.
- **📊 Productivity Insights**: Interactive charts showing your progress over the last 7 days and project distribution.
- **🌙 Advanced Theming**: Support for Light and Dark modes, including a **Scheduled Dark Mode** feature.
- **🔔 Local Notifications**: Smart reminders for your daily recap and upcoming tasks.
- **🛡️ Secure Auth**: Robust authentication powered by Firebase Auth and Google Sign-In.
- **⚡ Performance First**: Built with Riverpod for efficient state management and smooth animations (Confetti effects included!).

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Backend / DB**: [Firebase](https://firebase.google.com) (Firestore, Auth)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Icons**: [Lucide Icons](https://lucide.dev)
- **Typography**: [Google Fonts](https://fonts.google.com) (Outfit)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.10.7)
- Android Studio / VS Code with Flutter extensions
- A Firebase project for backend services

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/flowlife_mobile.git
   cd flowlife_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Add Android and/or iOS apps.
   - Download and place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── core/            # Business logic, providers, utilities
├── data/            # Models, services, repositories
└── presentation/    # UI Widgets, screens, theme
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---
*Built with ❤️ for better productivity.*
