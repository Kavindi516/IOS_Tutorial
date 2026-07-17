# PlayHub — iOS Mini-Games App

**Student Index:** COBSCCOMP251P-014
**Module:** iOS Application Development · BSCCOMP25.1P
**Platform:** iOS 17+ · Swift 5.10 · Xcode 15+

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Features List](#features-list)
3. [Known Limitations](#known-limitations)
4. [Reflection](#reflection)

---

## Architecture Overview

The repository contains **three Xcode projects** built progressively across the module weeks:

| Project | Purpose |
|---|---|
| `TutorialGame1/` | Week 1 starter — bare SwiftUI scaffold |
| `TapFrenzy/` | Week 2–3 standalone tap-speed mini-game |
| `LightItUp/` | Week 4 full multi-game hub (main deliverable) |

### Main Project — `LightItUp`

The final deliverable follows the **MVVM** (Model–View–ViewModel) pattern and is organised into clearly separated layers:

```
LightItUp/
├── App/
│   ├── LightItUpApp.swift      ← @main entry point + AppDelegate
│   └── RootView.swift          ← TabView shell (4 tabs)
│
├── Models/
│   ├── GameMode.swift          ← enum: tapFrenzy | lightItUp | quizRush
│   └── GameSession.swift       ← Codable struct + UserDefaults persistence
│
├── Services/
│   ├── LocationService.swift   ← CLLocationManager singleton (@MainActor)
│   ├── NotificationService.swift ← UNUserNotificationCenter scheduler
│   └── SessionSaver.swift      ← Bridges game-end → GameSession storage
│
├── ViewModels/
│   └── StatsViewModel.swift    ← @EnvironmentObject shared across all tabs
│
└── Views/
    ├── Tabs/
    │   ├── HomeTab.swift        ← Game picker, streak banner, daily challenge
    │   ├── StatsTab.swift       ← Charts framework bar chart + personal bests
    │   ├── MapTab.swift         ← MapKit map of where games were played
    │   └── SettingsTab.swift    ← Notifications toggle + time picker + reset
    └── Games/
        ├── TapFrenzyView.swift  ← Tap-speed game (self-contained, ~768 lines)
        ├── LightItUpView.swift  ← Reaction/card game view
        └── QuizRushView.swift   ← Live trivia game view
```

#### Supplementary Modules (inside `LightItUp/LightItUp/`)

```
LightItUp/               ← Card-game logic
│   ├── Card.swift
│   ├── CardView.swift
│   ├── Level.swift              ← 4-level progression enum (L1–L4)
│   └── LightItUpViewModel.swift
└── QuizRush/            ← Quiz-game logic
    ├── QuizQuestion.swift
    ├── QuizViewModel.swift
    ├── AnswerButton.swift
    └── TriviaService.swift      ← Open Trivia DB REST client (async/await)
```

#### Data & Communication Flow

```
Game ends
    └─► SessionSaver.save(mode:score:)
            └─► attaches GPS coordinate via LocationService.shared
            └─► persists GameSession to UserDefaults (JSON, key: gameSessions_v1)
            └─► posts NotificationCenter.default (.newSessionSaved)
                    └─► StatsViewModel.reload()
                            └─► publishes updated sessions[] → all tabs re-render
```

#### Key Architectural Decisions

- **Single source of truth for stats** — `StatsViewModel` is injected at the root via `.environmentObject()` so all four tabs share the same in-memory state without prop drilling.
- **`@AppStorage` for high scores** — Each game mode writes its personal best via `@AppStorage`, giving SwiftUI views automatic re-renders when a new record is set.
- **Service singletons** — `LocationService.shared` and `NotificationService.shared` are singleton classes; they hold OS-level delegates/handles that must persist for the app lifetime.
- **`@MainActor` for UI-bound services** — `LocationService` and `StatsViewModel` are annotated `@MainActor` so delegate callbacks update `@Published` properties safely without manual `DispatchQueue.main` calls.
- **`QuizViewState` enum** — Instead of Boolean flags, the quiz flow is driven by a single state enum with associated values (`failed(String)`), eliminating invalid state combinations.

---

## Features List

### 🏠 Home Tab
- **Game mode selector** — Card-style navigation links to each of the three mini-games, each showing the current personal best score.
- **Streak banner** — Displays the user's current consecutive-day streak and warns when today's game hasn't been played.
- **Daily challenge** — One-tap random-mode challenge with a completion indicator (checkmark once played today).
- **Notification bell** — Shows a red dot badge when notifications are enabled and the daily game hasn't been played.

### 🎮 Game Mode 1 — Tap Frenzy
- 30-second speed-tapping challenge.
- **Combo multiplier** — Consecutive taps without a miss build a combo; the pulsing `EnergyRing` visually reflects the current combo level with colour transitions (violet → cyan → gold).
- **Burst mode** — Hitting a high combo threshold triggers a burst animation.
- **Penalties** — Missed taps deduct from the combo and apply a score penalty.
- **Animated HUD** — Live score, combo counter, and countdown timer with colour shift as time runs low.
- **High-score persistence** via `@AppStorage`.

### 🌟 Game Mode 2 — Light It Up
- 60-second reaction game where randomly lit cards must be tapped before they go dark.
- **4 progressive difficulty levels** driven by elapsed time:

| Level | Starts At | Grid | Lit Window | Points/Tap |
|---|---|---|---|---|
| L1 (Sky Blue) | 0 s | 1×4 (4 cards) | 1.6 s | 10 |
| L2 (Mint) | 15 s | 2×3 (6 cards) | 1.2 s | 15 |
| L3 (Amber) | 30 s | 3×3 (9 cards) | 0.9 s | 20 |
| L4 (Red) | 45 s | 3×4 (12 cards) | 0.65 s | 30 |

- **3-lives system** — Tapping the wrong card or missing a lit card costs a life; game over when all lives are lost.
- **Level-up flash overlay** — Full-screen colour flash animates the transition between levels.
- **Configurable round length** — An in-game settings sheet lets the player choose a shorter or longer round.
- **New high-score detection** with a celebratory overlay.

### 🧠 Game Mode 3 — Quiz Rush
- 10 live multiple-choice trivia questions fetched from the **Open Trivia Database** (`opentdb.com`) via `async/await` HTTP.
- **Difficulty-scaled scoring:**
  - Easy → +10 pts · Medium → +20 pts · Hard → +30 pts
  - Wrong answer → −5 pts (floor at 0)
  - Every 3 correct in a row → +15 streak bonus
- **State-machine view model** — `QuizViewState` enum drives distinct screens: idle → loading → loaded → results / failed.
- **Deduplication** — Fetches 15 questions and deduplicates by question text before using the first 10.
- **Answer locking** — 0.9-second feedback window with correct/wrong highlighting before advancing.
- **Error recovery** — Network/decode failures surface a descriptive message with a Retry button.
- **High score** display on the start screen.

### 📊 Stats Tab
- **Overview cards** — Total games played, current streak, all-time best score.
- **Personal bests per mode** — Best score and total games played for each of the three game modes.
- **Bar chart** (Apple `Charts` framework) — Score history for the last 10 sessions of the selected mode, with a mode segmented picker.
- **Recent games list** — Latest 10 sessions with game mode icon, date/time, and score.
- **Empty state** — Friendly prompt shown before any games are recorded.

### 🗺️ Map Tab
- **MapKit map** showing a coloured pin for every session recorded with a GPS coordinate.
- Pin colour and icon matches the game mode (red = Tap Frenzy, blue = Light It Up, purple = Quiz Rush).
- Tapping a pin reveals a **session detail card** (mode, date, score) sliding up from the bottom.
- **Empty state** shown when no location data is available.

### ⚙️ Settings Tab
- **Notifications toggle** — Enables/disables all scheduled notifications; requests `UNUserNotificationCenter` permission on first enable.
- **Daily challenge time picker** — Wheel-style hour/minute picker; reschedules the `dailyChallenge` notification immediately on change.
- **Streak reminder** — Auto-scheduled at 20:00 daily when notifications are on.
- **Stats summary** — Quick view of total games and current streak.
- **Reset all stats** — Destructive action with a confirmation dialog; clears `UserDefaults` history and `@AppStorage` high scores.

### 🔔 Notifications (System Integration)
- `scheduleDailyChallenge(hour:minute:)` — Repeating `UNCalendarNotificationTrigger` at the user-chosen time.
- `scheduleStreakReminder()` — Repeating daily at 20:00 with a streak-break warning.
- Permission requested on app launch and again from the Settings tab.

### 📍 Location (System Integration)
- `CLLocationManager` with `requestWhenInUseAuthorization` and `kCLLocationAccuracyHundredMeters` accuracy.
- Location is silently attached to each `GameSession` if permission is granted; sessions without a coordinate are excluded from the Map tab.

---

## Known Limitations

1. **No iCloud sync / account system** — All game history is stored in `UserDefaults` on the local device. Uninstalling the app or switching devices permanently erases all data.

2. **Quiz Rush requires internet** — The trivia questions are fetched live from `opentdb.com`. There is no offline cache; if the device has no network connection the player sees an error screen and must retry.

3. **Open Trivia DB rate limiting** — The public API occasionally returns an empty result set or a rate-limit response, which surfaces as a generic error. There is no automatic back-off or retry delay implemented.

4. **Location accuracy is intentionally low** — `kCLLocationAccuracyHundredMeters` is used to reduce battery drain, but means map pins may be up to ~100 m from the actual play location.

5. **No background location** — Location is only captured at the exact moment a game ends (while the app is in the foreground). Switching to another app mid-game may result in a stale or missing coordinate.

6. **Streak calculation is device-clock dependent** — The streak counter reads `Calendar.current`. Travelling across time zones or changing the system clock can produce incorrect streak counts.

7. **Stats tab chart X-axis is hidden** — Because formatted date strings are too long to fit as bar-chart X-axis labels, the axis is suppressed entirely. The player cannot see the exact date of each bar without cross-referencing the Recent Games list.

8. **No iPad-specific layout** — The UI was designed and tested for iPhone (portrait). It will scale to iPad but without a split-view or adapted grid layout.

9. **`TutorialGame1` is a scaffold only** — The `TutorialGame1` Xcode project contains only the default SwiftUI "Hello, world!" template and is not a playable game; it represents the initial tutorial starting point.

10. **`TapFrenzy` standalone project is superseded** — The standalone `TapFrenzy/` project was the Week 2–3 deliverable. The version inside `LightItUp` (`TapFrenzyView.swift`) is the canonical, up-to-date implementation.

---

## Reflection

### What Went Well

Building this project was a genuine learning journey from the ground up in SwiftUI. The **MVVM pattern** clicked early and proved invaluable — keeping `LightItUpViewModel` and `QuizViewModel` entirely free of SwiftUI imports meant the game logic could be reasoned about in isolation. The decision to use a single `StatsViewModel` injected as an `@EnvironmentObject` at the root was the right call; adding the Map tab and Settings tab later required zero refactoring because they simply read from the shared object.

The **`QuizViewState` enum** is something I am particularly proud of. Early drafts used a tangle of `isLoading`, `hasError`, `showResults` booleans that created impossible-to-test state combinations (e.g., `isLoading = true` and `showResults = true` simultaneously). Collapsing everything into one enum with associated values eliminated that entire class of bug.

Integrating **Apple Charts** for the Stats bar chart was smoother than expected. The framework's declarative API composes naturally with SwiftUI, and learning to suppress the X-axis when labels would overflow was a small but satisfying problem to solve.

### Challenges Faced

The **`@MainActor` / concurrency** model was the steepest learning curve. `CLLocationManagerDelegate` methods are called on an unspecified thread, but `@Published` properties must be mutated on the main thread. The solution — marking `LocationService` as `@MainActor` and using `nonisolated` on the delegate methods with `Task { @MainActor in … }` — was non-obvious and required reading Apple's Swift Concurrency documentation carefully.

**Cross-ViewModel communication** was tricky. When a game ends, `SessionSaver` must trigger `StatsViewModel` to reload, but the ViewModel itself is not accessible from deep inside a game view. Using `NotificationCenter.default` as a lightweight internal event bus was a pragmatic solution, though it introduces implicit coupling that would be better replaced by a proper Combine publisher or actor-based approach in a production app.

The **Open Trivia DB integration** surfaced several edge cases that are easy to miss: HTML entity encoding in question strings (`&amp;`, `&#039;`, etc.), occasional duplicate questions in a single API response, and silent empty-result responses when the API is rate-limiting. Each required a defensive fix in `TriviaService`.

### What I Would Do Differently

- **Use `SwiftData` instead of `UserDefaults`** — Storing an array of `Codable` structs in `UserDefaults` works at this scale, but a proper `SwiftData` model store would give free iCloud sync via CloudKit, safer migrations, and proper querying.
- **Extract colour tokens into an Asset Catalog** — Defining hex colours inline throughout the codebase makes theme changes expensive. A single asset catalogue with named colours would be the correct approach.
- **Add unit tests for ViewModels** — The score, streak, and deduplication logic are deterministic and ideal for unit testing, but time constraints meant no test target was set up.
- **Implement an offline trivia cache** — Storing a bundled set of fallback questions would allow Quiz Rush to be played without internet, greatly improving the user experience in low-connectivity environments.

---

