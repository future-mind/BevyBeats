import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import '../models/track.dart';

class AudioPositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  AudioPositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });
}

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  // Stream that combines the current position, buffered position, and duration
  Stream<AudioPositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, AudioPositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => AudioPositionData(
          position: position,
          bufferedPosition: bufferedPosition,
          duration: duration ?? Duration.zero,
        ),
      );

  // Expose player streams directly
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;

  // Expose player controls
  bool get playing => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  // Initialize the audio service
  Future<void> init() async {
    // Set up audio session for background playback
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen for errors
    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        debugPrint('Error: $e');
      },
    );
  }

  // Load and play a single track
  Future<void> playSingleTrack(Track track) async {
    try {
      // Set the audio source
      final audioSource = AudioSource.uri(
        Uri.parse(track.streamUrl),
        tag: MediaItem(
          id: track.videoId,
          title: track.title,
          artist: track.artist,
          artUri: Uri.parse(track.thumbnailUrl),
          duration: Duration(seconds: track.durationSeconds),
        ),
      );

      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing track: $e');
      rethrow;
    }
  }

  // Load and play a list of tracks
  Future<void> playTracks(List<Track> tracks, {int initialIndex = 0}) async {
    try {
      // Create a playlist of audio sources
      final playlist = ConcatenatingAudioSource(
        children:
            tracks.map((track) {
              return AudioSource.uri(
                Uri.parse(track.streamUrl),
                tag: MediaItem(
                  id: track.videoId,
                  title: track.title,
                  artist: track.artist,
                  artUri: Uri.parse(track.thumbnailUrl),
                  duration: Duration(seconds: track.durationSeconds),
                ),
              );
            }).toList(),
      );

      // Set the audio source and initial index
      await _player.setAudioSource(playlist, initialIndex: initialIndex);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing tracks: $e');
      rethrow;
    }
  }

  // Playback controls
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> seekToNext() => _player.seekToNext();
  Future<void> seekToPrevious() => _player.seekToPrevious();
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  // Get the current track from the sequence state
  Track? getCurrentTrack(List<Track> tracks) {
    final index = _player.currentIndex;
    if (index != null && index >= 0 && index < tracks.length) {
      return tracks[index];
    }
    return null;
  }

  // Dispose of resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
