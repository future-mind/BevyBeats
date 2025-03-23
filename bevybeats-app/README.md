# BevyBeats App

The Flutter frontend for the BevyBeats music streaming application.

## Features

- Modern Spotify-like UI with dark theme
- Integration with multiple free music sources
- AI-powered music generation and recommendations
- Cross-platform support (iOS, Android, web, desktop)
- Offline playback capability

## Setup & Development

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode for mobile development
- VS Code or other IDE with Flutter extensions

### Getting Started

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bevybeats-app.git
cd bevybeats-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a `.env` file in the project root with the following contents:
```
API_BASE_URL=http://localhost:8000
YOUTUBE_MUSIC_API_KEY=your_api_key_here
GOOGLE_CLIENT_ID=your_client_id_here
```

4. Run the app:
```bash
# For debug mode
flutter run

# For specific platform
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d ios       # iOS
flutter run -d android   # Android
```

### Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── track.dart         # Track model
│   └── ...
├── providers/             # State management
│   ├── player_provider.dart  # Audio player state
│   └── ...
├── repositories/          # API integration
│   ├── youtube_music_repository.dart
│   ├── ai_repository.dart
│   └── ...
├── screens/               # App screens
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── create_music_screen.dart
│   ├── splash_screen.dart
│   └── ...
├── services/              # Business logic
│   ├── audio_service.dart
│   └── ...
├── utils/                 # Utilities
│   └── ...
└── widgets/               # Reusable UI components
    ├── mini_player.dart
    ├── track_tile.dart
    └── ...
```

## Architecture

The app follows a Provider-based architecture for state management:

1. **Models**: Data classes representing entities like tracks and playlists
2. **Repositories**: Handle API requests and data sources
3. **Providers**: Manage state and business logic
4. **Screens**: UI containers representing full pages
5. **Widgets**: Reusable UI components

## Key Components

### Player System

The audio playback system uses `just_audio` with background playback support. The `PlayerProvider` maintains the current queue and playback state.

### API Integration

The app communicates with the BevyBeats backend through repository classes that handle API requests, caching, and error handling.

### Local Storage

Hive is used for local storage to cache tracks, playlists, and user preferences for offline use.

## Testing

Run tests with:
```bash
flutter test
```

## Building for Production

Build release versions with:
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# macOS
flutter build macos --release
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request
