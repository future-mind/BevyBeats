# BevyBeats

BevyBeats is a cross-platform music streaming application that leverages free music sources, providing a Spotify-like experience with AI-powered features.

## Project Overview

The BevyBeats project consists of three main components:

1. **bevybeats-app**: The Flutter frontend application targeting iOS, Android, web, and desktop platforms
2. **bevybeats-backend**: The Python FastAPI backend services for music integration and AI features
3. **bevybot-assets**: Static assets and design resources, including the BevyBot mascot

## Features

- Modern and intuitive Spotify-like user interface with dark theme
- Cross-platform support (iOS, Android, web, desktop)
- Integration with multiple free music sources:
  - YouTube Music
  - SoundCloud
  - Free Music Archive
- AI-powered features using Mistral AI:
  - Music generation
  - Smart playlist curation
  - Personalized recommendations
- Google Sign-In for authentication
- Offline playback capability
- BevyBot AI assistant mascot

## Implementation Tracking

| Feature | Status | Priority | Phase |
|---------|--------|----------|-------|
| Project structure setup | ✅ | High | 1 |
| Basic UI implementation | ✅ | High | 1 |
| YouTube Music integration | ✅ | High | 1 |
| Google Sign-In | 🔄 | High | 1 |
| Backend API foundation | ✅ | High | 1 |
| SoundCloud integration | 🔄 | Medium | 2 |
| Free Music Archive integration | ❌ | Medium | 2 |
| Offline playback | ❌ | Medium | 2 |
| Smart search | ✅ | Medium | 2 |
| Mistral AI music generation | ✅ | Low | 3 |
| Mistral AI playlist curation | ✅ | Low | 3 |
| Social sharing | ❌ | Low | 3 |
| UI polish and animations | 🔄 | Low | 3 |

**Legend:**
- ✅ Completed
- 🔄 In Progress
- ❌ Not Started

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Python 3.8+
- Redis
- API keys for various services

### Quick Start

1. Clone the repositories:
```
git clone https://github.com/yourusername/bevybeats-app.git
git clone https://github.com/yourusername/bevybeats-backend.git
git clone https://github.com/yourusername/bevybot-assets.git
```

2. Set up the backend:
```
cd bevybeats-backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

3. Set up the Flutter app:
```
cd ../bevybeats-app
flutter pub get
```

4. Create `.env` files in both the app and backend directories with the necessary API keys.

5. Run the backend:
```
cd ../bevybeats-backend
python main.py
```

6. Run the Flutter app:
```
cd ../bevybeats-app
flutter run
```

## Architecture

The project follows a client-server architecture:

- **Frontend**: Flutter application with Provider/Bloc for state management
- **Backend**: Python FastAPI services with Redis caching
- **External APIs**: YouTube Music, SoundCloud, Free Music Archive, Mistral AI

## Development Guidelines

- Follow the Git Flow branching model
- Use descriptive commit messages
- Follow the style guides for each language/framework
- Write unit tests for all new features
- Document API endpoints and UI components 