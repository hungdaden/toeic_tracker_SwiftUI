# 🐱 TOEIC Tracker & Mun AI — SwiftUI Edition

A native iOS app ported from Flutter to **SwiftUI (iOS 17+)**, featuring a premium **Liquid Glass Dark Theme** with glassmorphism aesthetics, real-time **Firebase** integration, and full ETS 2026 exam support.

---

## ✨ Features

### 1. 📊 Score Progress Tracking
- **Swift Charts:** Smooth interactive line charts tracking **Listening** (cyan), **Reading** (orange), and **Total Score** (emerald) over time.
- **Circular Score Gauge:** Visual target score completion ring with remaining points indicator.
- **In-depth Statistics:** Highest score, latest score, average, and total exams taken.
- **Score History Cards:** Visual exam cards with detail view, edit, and quick-delete actions.

### 2. 📝 ETS TOEIC 2026 Exam Practice
- **Full ETS 2026 Tests:** Bundled official-format exams with 200 questions across all 7 Parts.
- **Native Audio & HD Images:** AVFoundation-powered audio playback with seek bar; Part 1 photos, Part 3/4 graphics, and Part 6/7 reading passages rendered natively.
- **Two Exam Modes:**
  - **Practice Mode:** Untimed, instant answer feedback with official explanations and audio transcripts.
  - **Timed Test Mode:** 120-minute countdown, auto-advancing Listening audio matching real exam pacing.
- **Question Grid Navigator:** Color-coded 200-question grid — green (answered), blue (current), gray (unanswered).
- **ETS Score Conversion:** Algorithm-based raw-to-scaled score conversion (5–495) per official ETS tables.

### 3. 🐱 Mun AI Assistant (Google Gemini)
- **Context-Aware Tutor:** Mun AI knows the student's name, target score, latest results, and weak areas to deliver personalized study strategies.
- **Online & Offline:** Connects to Google Gemini 2.0 Flash API when available; falls back to intelligent offline score analysis.
- **Quick Prompt Chips:** One-tap suggestions for Part 2 trap avoidance, Part 7 scanning strategy, and score breakthrough roadmaps.
- **Multi-Session Chat History:** Create, switch, and manage multiple conversation threads with Mun.

### 4. 🏆 Leaderboard & Streaks
- **Podium Top 3:** Gold 🥇, Silver 🥈, Bronze 🥉 with glowing Liquid Glass aura effects.
- **Individual & Group Modes:** Join study groups via 5-character codes to compete with friends.
- **Learning Streak 🔥:** Accurate daily-streak algorithm to motivate consistent English study habits.

### 5. 👥 Multi-User Profiles
- Add, edit, and delete independent student profiles.
- Quickly switch between profiles (e.g., Hưng, Hoa béo…).
- Toggle between **2-skill (Listening, Reading)** or **4-skill (Listening, Reading, Speaking, Writing)** mode.

### 6. 🔐 Firebase Integration
- **Firebase Authentication:** Email/password sign-in and sign-up via REST API with secure token persistence and auto-refresh.
- **Cloud Firestore:** Real-time user data, score history, and system configuration sync — zero local mock data dependency.
- **Maintenance Mode:** Remote kill-switch via Firestore `config/system` document for app-wide maintenance.

---

## 🏗 Architecture

**MVVM** with SwiftUI, leveraging `ObservableObject`, `@Published`, `@StateObject`, and `@ObservedObject` for reactive state management.

| Layer | Responsibility |
|---|---|
| **Models** | Data structures with `Codable` Firestore mapping |
| **Services** | Firebase Auth/Firestore REST, Gemini AI, audio playback, local storage |
| **ViewModels** | Business logic, state management, Firebase sync |
| **Views** | SwiftUI declarative UI with Liquid Glass theme |
| **Theme** | Design tokens, glassmorphism modifiers, reusable components |

---

## 📁 Project Structure

```text
Toeic Tracker SwiftUI/
├── ToeicTracker.xcodeproj
├── ToeicTracker/
│   ├── App/
│   │   └── ToeicTrackerApp.swift        # App entry point & auth routing
│   ├── Models/
│   │   ├── UserModel.swift              # Student profile & streak calculation
│   │   ├── ToeicScore.swift             # Score model (2/4-skill support)
│   │   ├── ToeicExam.swift              # 200-question exam structure (7 parts)
│   │   ├── ToeicScoreConverter.swift    # ETS raw-to-scaled conversion table
│   │   ├── MunAIChat.swift              # Chat messages & sessions
│   │   └── GroupModel.swift             # Study group model
│   ├── ViewModels/
│   │   ├── UserViewModel.swift          # User management, scores & Firebase sync
│   │   ├── ExamViewModel.swift          # Exam session, timer & grading logic
│   │   └── MunAIViewModel.swift         # AI chat & Gemini integration
│   ├── Services/
│   │   ├── FirebaseConfig.swift         # Firebase project config & REST base URLs
│   │   ├── AuthService.swift            # Firebase Auth REST API (sign-in/up, tokens)
│   │   ├── FirestoreService.swift       # Firestore REST API (users CRUD, scores)
│   │   ├── ExamService.swift            # Exam JSON loader & asset resolver
│   │   ├── GeminiAIService.swift        # Google Gemini 2.0 Flash / offline AI
│   │   ├── StorageService.swift         # Local persistence (UserDefaults)
│   │   └── AudioPlayerService.swift     # AVFoundation audio player
│   ├── Theme/
│   │   ├── LiquidGlassTheme.swift       # Dark obsidian palette, glass gradients
│   │   └── LiquidGlassModifiers.swift   # Glass card, chip, button modifiers
│   ├── Components/
│   │   ├── FloatingTabBar.swift         # Floating 5-tab navigation bar
│   │   ├── CircularProgressView.swift   # Target score gauge ring
│   │   ├── DynamicIslandNotification.swift  # Dynamic Island-style banner
│   │   └── ConfettiView.swift           # Confetti celebration effect
│   ├── Views/
│   │   ├── MainView.swift               # Root tab coordinator
│   │   ├── MaintenanceView.swift        # System maintenance screen
│   │   ├── Auth/
│   │   │   └── LoginView.swift          # Firebase authentication screen
│   │   ├── Home/
│   │   │   ├── HomeView.swift           # Dashboard with stats & charts
│   │   │   ├── ScoreChartView.swift     # Swift Charts score graph
│   │   │   └── ScoreCardView.swift      # Score history card
│   │   ├── Exams/
│   │   │   ├── ExamListView.swift       # Exam catalog browser
│   │   │   ├── ExamSessionView.swift    # 200-question exam session
│   │   │   ├── ExamModeModal.swift      # Practice/Test mode selector
│   │   │   ├── ExamResultSheet.swift    # Exam results summary
│   │   │   └── QuestionGridSheet.swift  # Question navigation grid
│   │   ├── MunAI/
│   │   │   ├── MunAIView.swift          # AI chat interface
│   │   │   ├── ChatBubbleView.swift     # Chat message bubble
│   │   │   └── ChatSessionDrawer.swift  # Chat session manager
│   │   ├── Leaderboard/
│   │   │   ├── LeaderboardView.swift    # Podium & rankings
│   │   │   └── GroupDialogView.swift    # Group join/create dialog
│   │   ├── Profile/
│   │   │   ├── ProfileView.swift        # Profile management
│   │   │   ├── EditUserSheet.swift      # Edit profile sheet
│   │   │   └── AddUserSheet.swift       # Add new profile sheet
│   │   ├── Score/
│   │   │   └── AddScoreSheet.swift      # Manual score entry form
│   │   └── LearningPath/
│   │       └── LearningPathView.swift   # Personalized study roadmap
│   └── Resources/
│       ├── Assets.xcassets              # App icon & asset catalog
│       ├── GoogleService-Info.plist     # Firebase configuration
│       ├── Info.plist                   # iOS bundle configuration
│       └── exams/                       # 186 files: 2 JSON, 108 MP3, 76 PNG
```

## 📝 License

This project is for personal educational use.
