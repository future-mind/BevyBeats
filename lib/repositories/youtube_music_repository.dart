import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/track.dart';

class YouTubeMusicRepository {
  final Dio _dio = Dio();
  final String _baseUrl;

  YouTubeMusicRepository()
    : _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<List<Track>> search(String query) async {
    try {
      // Use our backend as a proxy to YouTube Music API
      final response = await _dio.get(
        '$_baseUrl/api/youtube/search',
        queryParameters: {'query': query},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to search: ${response.statusCode}');
      }

      return _parseSearchResults(response.data);
    } catch (e) {
      // Error handling
      throw Exception('Failed to search tracks: $e');
    }
  }

  List<Track> _parseSearchResults(Map<String, dynamic> data) {
    List<Track> tracks = [];

    if (data.containsKey('tracks') && data['tracks'] is List) {
      for (var item in data['tracks']) {
        try {
          tracks.add(
            Track(
              id: item['videoId'] ?? '',
              title: item['title'] ?? '',
              artist: item['artist'] ?? '',
              albumArt: item['thumbnail'] ?? '',
              videoId: item['videoId'] ?? '',
              source: 'youtube',
            ),
          );
        } catch (e) {
          // Skip malformed items
          print('Error parsing track: $e');
        }
      }
    }

    return tracks;
  }

  Future<String> getStreamUrl(String videoId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/youtube/stream/$videoId');

      if (response.statusCode != 200) {
        throw Exception('Failed to get stream URL: ${response.statusCode}');
      }

      return response.data['streamUrl'] ?? '';
    } catch (e) {
      throw Exception('Failed to get stream URL: $e');
    }
  }

  Future<List<Track>> getRecommendations() async {
    try {
      final response = await _dio.get('$_baseUrl/api/youtube/recommendations');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to get recommendations: ${response.statusCode}',
        );
      }

      return _parseSearchResults(response.data);
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  Future<List<Track>> getPlaylistTracks(String playlistId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/youtube/playlist/$playlistId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get playlist: ${response.statusCode}');
      }

      return _parseSearchResults(response.data);
    } catch (e) {
      throw Exception('Failed to get playlist: $e');
    }
  }
}
