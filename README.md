<p align="center">
  <img src="assets/icon/ic_launcher.png" width="120" height="120" alt="SafeNews Logo" style="border-radius: 24px" />
</p>

# <p align="center">🛡️ SafeNews Mobile App</p>

<p align="center">
  <b>A smart, constructive, and positive news reading platform built with Flutter, Riverpod, and Firebase.</b><br>
  <i>Features Instant 0s AI Summaries, Floating Audio Player Bar, Vietnamese TTS Narration, and Reading Gamification.</i>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter 3.x" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart 3.x" /></a>
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/State_Management-Riverpod-blueviolet?style=for-the-badge" alt="Riverpod" /></a>
  <a href="https://m3.material.io"><img src="https://img.shields.io/badge/Design-Material_3-7B1FA2?style=for-the-badge&logo=materialdesign&logoColor=white" alt="Material 3" /></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Backend-Firebase_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase Firestore" /></a>
  <a href="https://deepmind.google/technologies/gemini/"><img src="https://img.shields.io/badge/AI-Gemini_2.5_Flash-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Gemini 2.5 Flash" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License MIT" /></a>
</p>

<p align="center">
  <a href="https://github.com/KhoaSinno/assignment_3_safe_news/releases/latest">
    <img src="https://img.shields.io/badge/📥_Download_Release_APK-v1.0.0_(48.3MB)-2ea44f?style=for-the-badge&logo=android&logoColor=white" alt="Download SafeNews APK" height="42" />
  </a>
</p>

---

## 📑 Table of Contents
- [Overview](#-overview)
- [Key Features](#-key-features)
- [App Architecture](#-app-architecture)
- [Project Directory Structure](#-project-directory-structure)
- [Quick Start Guide](#-quick-start-guide)
- [Makefile Commands](#-makefile-command-reference)
- [Gamification & Achievement System](#-gamification--achievement-system)
- [License](#-license)

---

## 🌐 Overview

**SafeNews** is a cross-platform mobile application developed with Flutter that shields readers from negative, sensationalist, and toxic news. By streaming AI-curated positive and safe articles directly from Cloud Firestore, SafeNews delivers a refreshing reading experience enhanced by instantaneous AI summaries, a floating audio player, Vietnamese voice narration, and reading gamification.

---

## 🌟 Key Features

* 🎵 **Floating Mini Audio Player**: Global persistent player widget with Play/Pause, speed adjustment (`0.75x`, `1.0x`, `1.25x`, `1.5x`), and status tracking.
* 🌿 **Sentiment Badges & Filter Chips**: Visual tags distinguishing `🌿 Positive News` from `🛡️ Safe Public Alerts`, with one-tap filtering in the home screen.
* ⚡ **Instant AI Summary (0s Delay)**: Pre-computed concise summaries delivered instantly from Firestore without client-side LLM latency.
* 🔍 **Smart Search & Clear Button**: Real-time debounced search with one-tap clear button (`X`).
* 🔎 **Accessibility Font Size Selector**: In-article `Aa` button allowing readers to scale text size (Small, Normal, Large, Extra Large).
* 🚩 **Active Learning User Reporting**: In-app article reporting dialog directly synced to Firestore to train and refine AI filters.
* 🗑️ **Bookmark Swipe-to-Delete with Undo**: Smooth `Dismissible` gesture with an instant `Undo` SnackBar.
* 🏆 **Gamification & Badges**: Tracks reading streaks, daily reading goals, and unlocks custom achievement badges.
* 📱 **Adaptive UI/UX (Material Design 3)**:
  * Dynamic Safe Area header adapts seamlessly to phone notches and Dynamic Island.
  * Real-time Light & Dark theme toggle with Riverpod state persistence.

---

## 🏗️ App Architecture

```
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                   │
│   (Screens, Widgets, Floating Audio Bar, Theme M3)     │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│                   RIVERPOD STATE LAYER                 │
│  (AudioPlayerProvider, ArticlesStream, BookmarkVM)     │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│                    DATA & CLOUD LAYER                  │
│    (Cloud Firestore, Firebase Auth, Hive Cache, TTS)   │
└────────────────────────────────────────────────────────┘
```

---

## 📁 Project Directory Structure

```
assignment_3_safe_news/
├── lib/
│   ├── constants/               # Global constants & categories
│   ├── features/
│   │   ├── authentication/      # Google Auth & Login/Signup
│   │   ├── bookmark/            # Bookmark screen, list & VM
│   │   ├── home/                # Feed, detail article, search & VM
│   │   └── profile/             # Profile, gamification & stats
│   ├── providers/               # Riverpod State Providers (Audio, Font, Theme)
│   ├── utils/                   # TTS service, cache manager, helpers
│   ├── widgets/                 # Floating audio bar, bottom nav, buttons
│   ├── main.dart                # App entrypoint
│   └── main_screen.dart         # Main container with IndexedStack & Floating Bar
└── Makefile                     # Build & device installation commands
```

---

## 🚀 Quick Start Guide

### Prerequisites
- Flutter SDK `3.x`
- Android Studio / VS Code
- Connected Android/iOS device or emulator

### Installation & Run
```bash
git clone https://github.com/KhoaSinno/assignment_3_safe_news.git
cd assignment_3_safe_news
flutter pub get

# Run in Debug mode with Hot Reload
make run-debug

# Install directly to USB connected device in Release mode
make install-device
```

---

## 🛠️ Makefile Command Reference

| Command | Action |
| :--- | :--- |
| `make run-debug` | Run the application in debug mode with hot reload |
| `make install-device` | Build & install the optimized release APK to connected phone |
| `make build-apk-release` | Compile a standalone release APK (`app-release.apk`) |
| `make clean` | Clean build artifacts and sync pub dependencies |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
