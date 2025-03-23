import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/track.dart';
import '../repositories/youtube_music_repository.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YouTubeMusicRepository _repository = YouTubeMusicRepository();
  Track? _currentTrack;
  List<Track> _queue = [];
  int _queueIndex = -1;
  double _volume = 1.0;
  RepeatMode _repeatMode = RepeatMode.off;
  bool _shuffleEnabled = false;

  PlayerProvider() {
    _initAudioPlayer();
  }

  // Getters
  Track? get currentTrack => _currentTrack;
  List<Track> get queue => List.unmodifiable(_queue);
  int get queueIndex => _queueIndex;
  bool get isPlaying => _audioPlayer.playing;
  double get volume => _audioPlayer.volume;
  Duration? get duration => _audioPlayer.duration;
  Duration? get position => _audioPlayer.position;
  RepeatMode get repeatMode => _repeatMode;
  bool get shuffleEnabled => _shuffleEnabled;
  
  // Streams for reactive UI
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  void _initAudioPlayer() {
    // Handle state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        // Auto-advance to next track when current track completes
        if (_repeatMode == RepeatMode.one) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else if (_queueIndex < _queue.length - 1 || _repeatMode == RepeatMode.all) {
          next();
        }
      }
      notifyListeners();
    });
  }

  // Play a single track immediately
  Future<void> play(Track track) async {
    try {
      _currentTrack = track;
      
      // Get stream URL if not already available
      if (track.streamUrl == null || track.streamUrl!.isEmpty) {
        final streamUrl = await _repository.getStreamUrl(track.id);
        _currentTrack = track.copyWith(streamUrl: streamUrl);
      }
      
      // Set audio source
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(_currentTrack!.streamUrl!),
          tag: MediaItem(
            id: _currentTrack!.id,
            title: _currentTrack!.title,
            artist: _currentTrack!.artist,
            artUri: Uri.parse(_currentTrack!.albumArtUrl),
            duration: _currentTrack!.duration,
          ),
        ),
      );
      
      // Start playback
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing track: $e');
      rethrow;
    }
  }
  
  // Set the queue and optionally start playing from a specific index
  Future<void> setQueue(List<Track> tracks, {int startIndex = 0, bool autoplay = true}) async {
    _queue = List.from(tracks);
    _queueIndex = startIndex.clamp(0, _queue.length - 1);
    notifyListeners();
    
    if (autoplay && _queue.isNotEmpty) {
      await play(_queue[_queueIndex]);
    }
  }
  
  // Add a track to the queue
  void addToQueue(Track track) {
    _queue.add(track);
    notifyListeners();
  }
  
  // Remove a track from the queue
  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      // Adjust current index if necessary
      if (index < _queueIndex) {
        _queueIndex--;
      } else if (index == _queueIndex && _queue.length > 1) {
        // If we're removing the current track, prepare to play the next one
        _queue.removeAt(index);
        if (_queueIndex >= _queue.length) {
          _queueIndex = 0;
        }
        play(_queue[_queueIndex]);
        return;
      }
      
      _queue.removeAt(index);
      notifyListeners();
    }
  }
  
  // Play the next track in the queue
  Future<void> next() async {
    if (_queue.isEmpty) return;
    
    if (_shuffleEnabled) {
      // Play a random track that's not the current one
      int nextIndex;
      do {
        nextIndex = (DateTime.now().millisecondsSinceEpoch % _queue.length).toInt();
      } while (_queue.length > 1 && nextIndex == _queueIndex);
      
      _queueIndex = nextIndex;
    } else {
      // Play the next track sequentially
      if (_queueIndex < _queue.length - 1) {
        _queueIndex++;
      } else if (_repeatMode == RepeatMode.all) {
        _queueIndex = 0; // Loop back to beginning
      } else {
        return; // No next track and not repeating
      }
    }
    
    await play(_queue[_queueIndex]);
  }
  
  // Play the previous track in the queue
  Future<void> previous() async {
    if (_queue.isEmpty) return;
    
    // If we're more than 3 seconds into the track, restart it instead of going to previous
    if (_audioPlayer.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      return;
    }
    
    if (_shuffleEnabled) {
      // Similar to next but going backwards in our shuffle history (if we had one)
      // For now, we'll just pick a different random track
      int prevIndex;
      do {
        prevIndex = (DateTime.now().millisecondsSinceEpoch % _queue.length).toInt();
      } while (_queue.length > 1 && prevIndex == _queueIndex);
      
      _queueIndex = prevIndex;
    } else {
      // Play the previous track sequentially
      if (_queueIndex > 0) {
        _queueIndex--;
      } else if (_repeatMode == RepeatMode.all) {
        _queueIndex = _queue.length - 1; // Loop to the end
      } else {
        return; // No previous track and not repeating
      }
    }
    
    await play(_queue[_queueIndex]);
  }
  
  // Toggle play/pause
  void togglePlayPause() {
    if (_audioPlayer.playing) {
      pause();
    } else {
      resume();
    }
  }
  
  // Pause playback
  void pause() {
    _audioPlayer.pause();
    notifyListeners();
  }
  
  // Resume playback
  void resume() {
    _audioPlayer.play();
    notifyListeners();
  }
  
  // Seek to a specific position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }
  
  // Set volume (0.0 to 1.0)
  void setVolume(double volume) {
    volume = volume.clamp(0.0, 1.0);
    _audioPlayer.setVolume(volume);
    _volume = volume;
    notifyListeners();
  }
  
  // Toggle shuffle mode
  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    notifyListeners();
  }
  
  // Set repeat mode (cycle through off, all, one)
  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

enum RepeatMode {
  off,
  all,
  one,
} 
} 