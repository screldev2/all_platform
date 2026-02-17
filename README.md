# Google WebView App 🚀

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-green?style=for-the-badge)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

A sleek, modern Flutter application that provides a seamless WebView experience for Google services. Built with **Clean Architecture** principles to ensure scalability, maintainability, and robust performance.

---

## ✨ Key Features

- 🌐 **Advanced WebView integration**: Uses `flutter_inappwebview` for high-performance web content rendering.
- 📶 **Real-time Connectivity Handling**: Automatically detects network status changes and provides elegant offline screens.
- 🛠️ **Centralized Configuration**: All app-wide constants, colors, and strings are managed in a single `AppConstants` file.
- 📱 **Platform Optimizations**: Custom User-Agents and status bar styling for a native-like feel on Android, iOS, and Windows.
- 🔄 **Smart Retry Logic**: Intuitive troubleshooting tips and "Try Again" mechanisms for network errors.
- 🚪 **Proactive Exit Confirmation**: Prevents accidental app closures with a user-friendly dialog.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (^3.10.1)
- **Language**: [Dart](https://dart.dev)
- **Networking**: `connectivity_plus`
- **WebView**: `flutter_inappwebview`
- **Utilities**: `url_launcher`, `flutter_native_splash`, `flutter_launcher_icons`

---

## 📂 Project Structure

The project follows a modular **Clean Architecture** pattern:

```text
lib/
├── core/
│   └── constants/      # AppConstants and global configurations
├── features/
│   └── webview/        # Main WebView feature
│       ├── data/       # Repositories and Data Sources
│       ├── domain/     # Entities and Repository interfaces
│       └── presentation/ # Widgets, Pages, and Logic
└── main.dart           # App entry point & dependency injection
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.10.1)
- Android Studio / VS Code with Flutter extensions
- A mobile device or emulator

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/project_google.git
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🎨 UI Highlights

- **Custom Splash Screen**: Smooth transition from launch to app.
- **Dynamic Status Bar**: Adapts to the app's aesthetic (Light/Dark mode icons).
- **Graceful Error States**: Professional offline and error screens with actionable troubleshooting tips.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by the Flutter Dev Team
</p>
