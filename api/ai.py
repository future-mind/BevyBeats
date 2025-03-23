from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional
import os
from dotenv import load_dotenv
import json
import httpx

# Load environment variables
load_dotenv()

router = APIRouter(prefix="/api/ai", tags=["ai"])

class PlaylistRequest(BaseModel):
    prompt: str
    max_songs: int = 10

class MusicGenerationRequest(BaseModel):
    prompt: str
    duration: Optional[int] = 30  # Duration in seconds

class Track(BaseModel):
    videoId: str
    title: str
    artist: str
    thumbnail: str
    duration: str

class PlaylistResponse(BaseModel):
    playlist_name: str
    tracks: List[Track]

@router.post("/generate-playlist", response_model=PlaylistResponse)
async def generate_playlist(request: PlaylistRequest):
    """
    Generate a playlist based on user prompt using Mistral AI.
    """
    try:
        # In a production app, this would call the Mistral AI API
        # For demo purposes, we'll return placeholder data
        
        # Mock implementation
        prompt_lower = request.prompt.lower()
        playlist_name = f"Playlist for: {request.prompt}"
        
        # Simulate AI-based genre/mood detection
        genres = []
        if "rock" in prompt_lower:
            genres.append("rock")
        if "pop" in prompt_lower:
            genres.append("pop")
        if "hip hop" in prompt_lower or "rap" in prompt_lower:
            genres.append("hip-hop")
        if "jazz" in prompt_lower:
            genres.append("jazz")
        if "classical" in prompt_lower:
            genres.append("classical")
        
        moods = []
        if "happy" in prompt_lower or "upbeat" in prompt_lower:
            moods.append("happy")
        if "sad" in prompt_lower or "melancholy" in prompt_lower:
            moods.append("sad")
        if "relax" in prompt_lower or "calm" in prompt_lower:
            moods.append("relaxing")
        if "energetic" in prompt_lower or "workout" in prompt_lower:
            moods.append("energetic")
        
        # If no specific genres/moods detected, use general recommendations
        if not genres and not moods:
            tracks = [
                Track(
                    videoId="dQw4w9WgXcQ",
                    title="Never Gonna Give You Up",
                    artist="Rick Astley",
                    thumbnail="https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
                    duration="3:32",
                ),
                Track(
                    videoId="y6120QOlsfU",
                    title="Sandstorm",
                    artist="Darude",
                    thumbnail="https://i.ytimg.com/vi/y6120QOlsfU/hqdefault.jpg",
                    duration="3:53",
                ),
                Track(
                    videoId="L_jWHffIx5E",
                    title="All Star",
                    artist="Smash Mouth",
                    thumbnail="https://i.ytimg.com/vi/L_jWHffIx5E/hqdefault.jpg",
                    duration="3:15",
                ),
            ]
        else:
            # Mock different tracks based on detected genres/moods
            if "rock" in genres:
                tracks = [
                    Track(
                        videoId="1w7OgIMMRc4",
                        title="Stairway to Heaven",
                        artist="Led Zeppelin",
                        thumbnail="https://i.ytimg.com/vi/1w7OgIMMRc4/hqdefault.jpg",
                        duration="8:02",
                    ),
                    Track(
                        videoId="WyF8RHM1OCg",
                        title="Bohemian Rhapsody",
                        artist="Queen",
                        thumbnail="https://i.ytimg.com/vi/WyF8RHM1OCg/hqdefault.jpg",
                        duration="5:55",
                    ),
                ]
            elif "pop" in genres:
                tracks = [
                    Track(
                        videoId="kJQP7kiw5Fk",
                        title="Despacito",
                        artist="Luis Fonsi ft. Daddy Yankee",
                        thumbnail="https://i.ytimg.com/vi/kJQP7kiw5Fk/hqdefault.jpg",
                        duration="4:41",
                    ),
                    Track(
                        videoId="JGwWNGJdvx8",
                        title="Shape of You",
                        artist="Ed Sheeran",
                        thumbnail="https://i.ytimg.com/vi/JGwWNGJdvx8/hqdefault.jpg",
                        duration="4:23",
                    ),
                ]
            else:
                tracks = [
                    Track(
                        videoId="9bZkp7q19f0",
                        title="Gangnam Style",
                        artist="PSY",
                        thumbnail="https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg",
                        duration="4:12",
                    ),
                    Track(
                        videoId="OPf0YbXqDm0",
                        title="Uptown Funk",
                        artist="Mark Ronson ft. Bruno Mars",
                        thumbnail="https://i.ytimg.com/vi/OPf0YbXqDm0/hqdefault.jpg",
                        duration="4:30",
                    ),
                ]
        
        # Limit the number of tracks to max_songs
        tracks = tracks[:request.max_songs]
        
        return PlaylistResponse(
            playlist_name=playlist_name,
            tracks=tracks,
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating playlist: {str(e)}")

@router.post("/generate-music")
async def generate_music(request: MusicGenerationRequest):
    """
    Generate music based on a text prompt using Mistral AI.
    """
    try:
        # In a production app, this would call Mistral AI or another model
        # For demo purposes, we'll return a placeholder
        
        return {
            "message": "Music generation is not yet implemented.",
            "prompt": request.prompt,
            "duration": request.duration,
            # In a real implementation, this would return an audio URL or file
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating music: {str(e)}")

@router.post("/enhance-prompt")
async def enhance_prompt(prompt: str):
    """
    Enhance a user's simple prompt into a more detailed one for better results.
    """
    try:
        # In a production app, this would use Mistral AI to enhance the prompt
        # For demo purposes, we'll return a simple enhancement
        
        enhanced_prompt = f"Creating a personalized playlist with {prompt}, " \
                         f"featuring a mix of popular hits and lesser-known gems " \
                         f"that match this theme, with a good balance of energy levels."
        
        return {
            "original_prompt": prompt,
            "enhanced_prompt": enhanced_prompt,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error enhancing prompt: {str(e)}") 