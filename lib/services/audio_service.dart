import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../repositories/youtube_music_repository.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YouTubeMusicRepository _youtubeRepository = YouTubeMusicRepository();

  // Expose audio player streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  AudioService() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Set up event listeners, error handling, etc.
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Handle track completion
      }
    });

    _audioPlayer.playbackEventStream.listen(
      (event) {
        // Handle playback events
      },
      onError: (Object e, StackTrace st) {
        if (kDebugMode) {
          print('A stream error occurred: $e');
        }
      },
    );
  }

  Future<void> playTrack(Track track) async {
    try {
      // Get the streaming URL based on the source
      String streamUrl = await _getStreamUrl(track);

      // Create media item for background playback
      MediaItem mediaItem = MediaItem(
        id: track.id,
        album: track.artist,
        title: track.title,
        artUri: Uri.parse(track.albumArt),
      );

      // Play the audio
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(streamUrl), tag: mediaItem),
      );

      await _audioPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing track: $e');
      }
      rethrow;
    }
  }

  Future<String> _getStreamUrl(Track track) async {
    switch (track.source) {
      case 'youtube':
        return await _youtubeRepository.getStreamUrl(track.videoId);
      case 'soundcloud':
        // Implement SoundCloud streaming
        return '';
      case 'fma':
        // Implement Free Music Archive streaming
        return '';
      default:
        throw Exception('Unsupported source: ${track.source}');
    }
  }

  // Basic playback controls
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
