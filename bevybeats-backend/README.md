# BevyBeats Backend

The FastAPI backend for the BevyBeats music streaming application, providing API endpoints for music services integration and AI features.

## Features

- FastAPI-based RESTful API
- YouTube Music API integration
- Mistral AI integration for music generation and recommendations
- API endpoints for track search, playback, and recommendations
- Cross-origin resource sharing (CORS) support

## Setup & Development

### Prerequisites

- Python 3.8+
- Poetry (optional but recommended for dependency management)
- Redis (for caching)
- API keys for external services

### Getting Started

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bevybeats-backend.git
cd bevybeats-backend
```

2. Set up a virtual environment and install dependencies:
```bash
# Using poetry (recommended)
poetry install

# Or using pip with virtualenv
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. Create a `.env` file in the project root with the following contents:
```
# Server settings
PORT=8000
DEBUG=true
ENVIRONMENT=development

# API keys
YOUTUBE_MUSIC_API_KEY=your_youtube_music_api_key
MISTRAL_AI_API_KEY=your_mistral_ai_api_key

# Redis settings
REDIS_URL=redis://localhost:6379/0
```

4. Run the server:
```bash
# Using poetry
poetry run python main.py

# Or directly
python main.py
```

5. The API will be available at http://localhost:8000

### Project Structure

```
bevybeats-backend/
├── api/                  # API endpoints
│   ├── __init__.py
│   ├── youtube.py        # YouTube Music endpoints
│   ├── ai.py             # AI-related endpoints
│   └── ...
├── core/                 # Core functionality
│   ├── config.py         # Configuration settings
│   ├── security.py       # Authentication
│   └── ...
├── models/               # Data models
│   ├── track.py
│   └── ...
├── services/             # Business logic and external services
│   ├── youtube_music.py  # YouTube Music API client
│   ├── mistral_ai.py     # Mistral AI client
│   └── ...
├── utils/                # Utility functions
│   └── ...
├── main.py               # App entry point
├── requirements.txt      # Dependencies
└── .env                  # Environment variables
```

## API Endpoints

### YouTube Music API

- `GET /api/youtube/search?q={query}` - Search for tracks
- `GET /api/youtube/track/{track_id}` - Get track details
- `GET /api/youtube/recommendations` - Get recommended tracks

### AI Features

- `POST /api/ai/generate-music` - Generate music based on a prompt
- `POST /api/ai/curate-playlist` - Create a playlist based on a description

### Utility Endpoints

- `GET /health` - Health check endpoint
- `GET /` - API welcome message

## Development Guidelines

### Adding New Endpoints

1. Create a new router file in the `api` directory or add to an existing one
2. Import and include the router in `main.py`
3. Add appropriate request/response models

### Working with External APIs

1. Create a new service class in the `services` directory
2. Implement the necessary methods to interact with the external API
3. Use the service in the appropriate API endpoint

## Testing

Run tests with:
```bash
# Using poetry
poetry run pytest

# Or directly
pytest
```

## Deployment

### Docker

A Dockerfile is provided for containerization:

```bash
# Build the image
docker build -t bevybeats-backend .

# Run the container
docker run -p 8000:8000 --env-file .env bevybeats-backend
```

### Server Deployment

For production deployment, consider using Gunicorn with Uvicorn workers:

```bash
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request
