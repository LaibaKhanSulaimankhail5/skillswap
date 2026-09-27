# SkillSwap – Campus Skill Exchange Platform

SkillSwap is a Flutter and Firebase mobile application that lets students exchange
skills with each other without any monetary payment. A student who can teach
Flutter, for example, can connect with another student who can teach UI/UX
design — both learn, nobody pays.

## Features

- **Authentication** — Email/Password, Google Sign-In, Guest Login, and Phone
  Number (OTP) verification via Firebase Authentication
- **Profiles** — Skills to teach/learn, bio, and profile picture (stored as
  compressed Base64 in Firestore — no paid storage required)
- **Discovery & Matching** — Search and browse students, with a keyword-based
  matching algorithm that highlights Great Matches and partial matches
- **Skill Exchange Requests** — Send a request with an optional message,
  Accept/Reject from a dedicated screen
- **Real-Time Chat** — WhatsApp-style messaging with date separators,
  timestamps, and tap-to-view profile
- **Ratings, Credits & Badges** — Rate exchange partners, earn credits, and
  unlock achievement badges automatically
- **Leaderboard** — Ranks the most helpful students by credits earned
- **Light/Dark Theme** — Toggleable, persists across app restarts
- **Offline Support** — Local SQLite cache keeps profile and discovery data
  available without an internet connection

## Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Authentication, Cloud Firestore)
- **Local Storage:** SQLite (sqflite)
- **State Management:** Provider

## Project Structure

lib/
├── core/ # Theme, constants, utilities, shared widgets
├── data/ # Models, repositories, services (Firestore, Auth, DB)
├── presentation/ # UI screens grouped by feature (auth, profile, chat, etc.)
└── services/ # Provider classes for state management


## Getting Started

1. Clone the repo
2. Run `flutter pub get`
3. Add your own `google-services.json` (Android) via Firebase Console
4. Run `flutterfire configure` to generate `firebase_options.dart`
5. Run `flutter run`

## Author

**Laiba Khan** — BS Software Engineering, PAF-IAST
