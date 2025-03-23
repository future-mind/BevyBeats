from fastapi import APIRouter, HTTPException, Query
from typing import Optional, List, Dict, Any
import httpx
import os
from dotenv import load_dotenv
import json
from ytmusicapi import YTMusic
from pytube import YouTube  # Add pytube for stream extraction

# Load environment variables
load_dotenv()

router = APIRouter(prefix="/api/youtube", tags=["youtube"])

# Initialize YTMusic API
ytmusic = YTMusic()

@router.get("/search")
async def search_youtube_music(query: str, filter: Optional[str] = None) -> Dict[str, Any]:
    """
    Search YouTube Music and return results.
    """
    try:
        # Use YTMusic library to search
        search_results = ytmusic.search(query=query, filter=filter or None)
        
        # Process search results
        tracks = []
        for item in search_results:
            if item.get('resultType') == 'song' or item.get('type') == 'song':
                try:
                    video_id = item.get('videoId')
                    if not video_id:
                        continue
                        
                    track = {
                        'videoId': video_id,
                        'title': item.get('title', ''),
                        'artist': item.get('artists', [{}])[0].get('name', '') if item.get('artists') else '',
                        'thumbnail': (
                            item.get('thumbnails', [{}])[-1].get('url', '')
                            if item.get('thumbnails') else ''
                        ),
                        'duration': item.get('duration', ''),
                    }
                    tracks.append(track)
                except Exception as e:
                    # Skip malformed items
                    print(f"Error processing track: {e}")
        
        return {"tracks": tracks}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error searching YouTube Music: {str(e)}")

@router.get("/stream/{video_id}")
async def get_stream_url(video_id: str) -> Dict[str, str]:
    """
    Get the streaming URL for a YouTube Music track using pytube.
    """
    try:
        # Create a YouTube object
        yt = YouTube(f"https://www.youtube.com/watch?v={video_id}")
        
        # Get the audio stream (we prefer highest quality audio)
        audio_stream = yt.streams.filter(only_audio=True).order_by('abr').desc().first()
        
        if not audio_stream:
            raise HTTPException(status_code=404, detail="No audio stream found for this video")
        
        # Get the streaming URL
        stream_url = audio_stream.url
        
        # Return the streaming URL and additional metadata
        return {
            "streamUrl": stream_url,
            "title": yt.title,
            "author": yt.author,
            "lengthSeconds": yt.length,
            "videoId": video_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting stream URL: {str(e)}")

@router.get("/recommendations")
async def get_recommendations() -> Dict[str, Any]:
    """
    Get recommended tracks from YouTube Music.
    """
    try:
        # Get actual recommendations from YouTube Music API
        # This gets the "Home" feed which includes recommendations
        home_data = ytmusic.get_home()
        
        # Process the home data to extract recommended tracks
        tracks = []
        
        # Look for a section with recommendations
        recommendation_sections = [section for section in home_data if "content" in section]
        
        if recommendation_sections:
            # Pick the first section that has recommendations
            for section in recommendation_sections:
                for item in section.get("content", [])[:10]:  # Limit to 10 tracks
                    if item.get("videoId"):
                        try:
                            track = {
                                'videoId': item.get('videoId'),
                                'title': item.get('title', ''),
                                'artist': item.get('artists', [{}])[0].get('name', '') if item.get('artists') else '',
                                'thumbnail': (
                                    item.get('thumbnails', [{}])[-1].get('url', '')
                                    if item.get('thumbnails') else ''
                                ),
                                'duration': item.get('duration', ''),
                            }
                            tracks.append(track)
                        except Exception as e:
                            # Skip malformed items
                            print(f"Error processing recommendation: {e}")
                
                # If we found tracks in this section, break the loop
                if tracks:
                    break
        
        # Fallback to mock data if no recommendations were found
        if not tracks:
            tracks = [
                {
                    'videoId': 'dQw4w9WgXcQ',
                    'title': 'Never Gonna Give You Up',
                    'artist': 'Rick Astley',
                    'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
                    'duration': '3:32',
                }
                # ... other mock tracks
            ]
        
        return {"tracks": tracks}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting recommendations: {str(e)}")

@router.get("/playlist/{playlist_id}")
async def get_playlist(playlist_id: str) -> Dict[str, Any]:
    """
    Get tracks from a YouTube Music playlist.
    """
    try:
        # Get playlist tracks from YTMusic
        playlist_tracks = ytmusic.get_playlist(playlist_id)
        
        # Process playlist tracks
        tracks = []
        for item in playlist_tracks.get('tracks', []):
            try:
                video_id = item.get('videoId')
                if not video_id:
                    continue
                    
                track = {
                    'videoId': video_id,
                    'title': item.get('title', ''),
                    'artist': item.get('artists', [{}])[0].get('name', '') if item.get('artists') else '',
                    'thumbnail': (
                        item.get('thumbnails', [{}])[-1].get('url', '')
                        if item.get('thumbnails') else ''
                    ),
                    'duration': item.get('duration', ''),
                }
                tracks.append(track)
            except Exception as e:
                # Skip malformed items
                print(f"Error processing track: {e}")
        
        return {"tracks": tracks}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting playlist: {str(e)}")

@router.get("/track/{video_id}")
async def get_track_details(video_id: str) -> Dict[str, Any]:
    """
    Get detailed information about a specific track.
    """
    try:
        # Get track details from YTMusic API
        track_info = ytmusic.get_song(video_id)
        
        # Process track details
        track = {
            'videoId': video_id,
            'title': track_info.get('title', ''),
            'artist': track_info.get('artistName', ''),
            'album': track_info.get('album', {}).get('name', ''),
            'thumbnail': (
                track_info.get('thumbnails', [{}])[-1].get('url', '')
                if track_info.get('thumbnails') else ''
            ),
            'duration': track_info.get('duration', ''),
            'viewCount': track_info.get('viewCount', ''),
            'likeCount': track_info.get('likeCount', ''),
        }
        
        return {"track": track}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting track details: {str(e)}") 