import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/track.dart';

class YouTubeMusicRepository {
  final Dio _dio = Dio();
  final String baseUrl;

  YouTubeMusicRepository({String? baseUrl})
    : baseUrl =
          baseUrl ?? dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  // Search for tracks
  Future<List<Track>> searchTracks(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/youtube/search',
        queryParameters: {'query': query},
      );

      if (response.statusCode == 200 && response.data['tracks'] != null) {
        final List<dynamic> tracksJson = response.data['tracks'];
        return tracksJson
            .map((json) => Track.fromYouTubeJson(json, ''))
            .toList();
      } else {
        throw Exception('Failed to search tracks');
      }
    } catch (e) {
      debugPrint('Error searching tracks: $e');
      throw Exception('Failed to search tracks: $e');
    }
  }

  // Get recommendations
  Future<List<Track>> getRecommendations() async {
    try {
      final response = await _dio.get('$baseUrl/api/youtube/recommendations');

      if (response.statusCode == 200 && response.data['tracks'] != null) {
        final List<dynamic> tracksJson = response.data['tracks'];
        return tracksJson
            .map((json) => Track.fromYouTubeJson(json, ''))
            .toList();
      } else {
        throw Exception('Failed to get recommendations');
      }
    } catch (e) {
      debugPrint('Error getting recommendations: $e');
      throw Exception('Failed to get recommendations: $e');
    }
  }

  // Get playlist tracks
  Future<List<Track>> getPlaylistTracks(String playlistId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/youtube/playlist/$playlistId',
      );

      if (response.statusCode == 200 && response.data['tracks'] != null) {
        final List<dynamic> tracksJson = response.data['tracks'];
        return tracksJson
            .map((json) => Track.fromYouTubeJson(json, ''))
            .toList();
      } else {
        throw Exception('Failed to get playlist tracks');
      }
    } catch (e) {
      debugPrint('Error getting playlist tracks: $e');
      throw Exception('Failed to get playlist tracks: $e');
    }
  }

  // Get track details
  Future<Track> getTrackDetails(String videoId) async {
    try {
      final response = await _dio.get('$baseUrl/api/youtube/track/$videoId');

      if (response.statusCode == 200 && response.data['track'] != null) {
        return Track.fromYouTubeJson(response.data['track'], '');
      } else {
        throw Exception('Failed to get track details');
      }
    } catch (e) {
      debugPrint('Error getting track details: $e');
      throw Exception('Failed to get track details: $e');
    }
  }

  // Get stream URL for a track
  Future<String> getStreamUrl(String videoId) async {
    try {
      final response = await _dio.get('$baseUrl/api/youtube/stream/$videoId');

      if (response.statusCode == 200 && response.data['streamUrl'] != null) {
        return response.data['streamUrl'];
      } else {
        throw Exception('Failed to get stream URL');
      }
    } catch (e) {
      debugPrint('Error getting stream URL: $e');
      throw Exception('Failed to get stream URL: $e');
    }
  }
}
