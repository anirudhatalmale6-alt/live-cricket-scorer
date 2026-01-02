# Live Cricket Scorer

A cross-platform live cricket scoring application built with Flutter that runs smoothly on iOS, Android, and the Web from a single codebase.

## Features

### 1. Real-Time Score Updates
- Instant score updates as balls are recorded
- Live match tracking with current run rate and required run rate
- Ball-by-ball commentary and over tracking
- Visual display of current over deliveries

### 2. Player Statistics
- Comprehensive batting statistics (runs, average, strike rate, 4s, 6s)
- Bowling statistics (wickets, economy, average, best figures)
- Fielding statistics (catches, run outs, stumpings)
- Persistent storage across sessions
- Search and filter players by team and role

### 3. Match Scheduling
- Schedule upcoming matches with date/time picker
- Support for all cricket formats:
  - T20 (20 overs)
  - ODI (50 overs)
  - Test
  - T10 (10 overs)
  - The Hundred
  - Custom format
- Venue and team selection
- Easy match management

### 4. Team Management
- Create and manage teams
- Add players with roles (Batsman, Bowler, All-Rounder, Wicket Keeper)
- Sample teams available for quick start (MI, CSK)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── player.dart          # Player model with stats
│   ├── team.dart            # Team model
│   ├── match.dart           # Match model with formats
│   ├── innings.dart         # Innings tracking
│   ├── ball_event.dart      # Individual ball events
│   └── models.dart          # Export file
├── providers/                # State management
│   ├── match_provider.dart  # Match state and live scoring
│   └── team_provider.dart   # Team/player management
├── screens/                  # UI screens
│   ├── home_screen.dart     # Main dashboard with tabs
│   ├── live_scoring_screen.dart  # Live match scoring
│   ├── schedule_match_screen.dart # Create new match
│   ├── player_stats_screen.dart   # Player statistics
│   ├── teams_screen.dart    # Team management
│   └── screens.dart         # Export file
├── services/                 # Business logic
│   ├── storage_service.dart # Persistent storage
│   └── live_score_service.dart # Real-time updates
├── utils/                    # Utilities
│   └── app_theme.dart       # App theming
└── widgets/                  # Reusable UI components
    ├── score_card.dart      # Match score display
    ├── scoring_panel.dart   # Scoring input buttons
    ├── batsman_card.dart    # Current batsmen display
    ├── player_stats_card.dart # Player stats display
    ├── match_tile.dart      # Match list item
    └── widgets.dart         # Export file
```

## Getting Started

### Prerequisites
- Flutter SDK 3.10.4 or higher
- Dart SDK 3.10.4 or higher
- For iOS: Xcode 15+ and CocoaPods
- For Android: Android Studio and Android SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/anirudhatalmale9-star/live-cricket-scorer.git
cd live-cricket-scorer
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web
flutter run -d chrome

# For iOS (macOS only)
flutter run -d ios

# For Android
flutter run -d android
```

## Building Release Versions

### Web
```bash
flutter build web --release
# Output: build/web/
```

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires macOS)
```bash
flutter build ios --release
# Then archive in Xcode for .ipa
```

## Usage

### Quick Start
1. Launch the app
2. Go to "Teams & Players" (icon in app bar)
3. Click "Add Sample Teams" for quick demo data
4. Schedule a new match from the home screen
5. Start the match, select toss winner
6. Begin scoring!

### Scoring a Match
1. Select opening batsmen and bowler
2. Use the scoring panel to record each ball:
   - Tap runs (0-6)
   - Tap 4/6 for boundaries
   - Tap Wide/No Ball/Bye/Leg Bye for extras
   - Tap Wicket for dismissals
3. Use Undo to correct mistakes
4. Use Swap to manually rotate strike

### Viewing Statistics
- Navigate to Player Stats from home screen
- Filter by batting/bowling rankings
- Search for specific players
- Tap player for detailed stats

## Technology Stack

- **Framework**: Flutter 3.10.4
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Date Formatting**: intl package
- **Architecture**: Clean Architecture with MVVM

## License

This project is licensed under the MIT License.

## Support

For questions or issues, please open a GitHub issue.
