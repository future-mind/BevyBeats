import 'package:flutter/foundation.dart';
import '../models/track.dart';

class PlayerProvider with ChangeNotifier {
  Track? _currentTrack;
  bool _isPlaying = false;
  double _progress = 0.0;
  double _duration = 0.0;
  List<Track> _queue = [];
  int _currentIndex = -1;

  Track? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  double get progress => _progress;
  double get duration => _duration;
  List<Track> get queue => _queue;
  int get currentIndex => _currentIndex;

  void play(Track track) {
    _currentTrack = track;
    _isPlaying = true;
    notifyListeners();
    // Actual playback logic will be handled by AudioService
  }

  void playFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      _currentTrack = _queue[index];
      _isPlaying = true;
      notifyListeners();
    }
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void resume() {
    _isPlaying = true;
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    _currentTrack = null;
    _progress = 0.0;
    notifyListeners();
  }

  void updateProgress(double value) {
    _progress = value;
    notifyListeners();
  }

  void setDuration(double value) {
    _duration = value;
    notifyListeners();
  }

  void seekTo(double position) {
    _progress = position;
    notifyListeners();
  }

  void addToQueue(Track track) {
    _queue.add(track);
    if (_currentIndex == -1) {
      _currentIndex = 0;
      _currentTrack = track;
    }
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      bool removingCurrentTrack = index == _currentIndex;
      _queue.removeAt(index);

      if (_queue.isEmpty) {
        _currentIndex = -1;
        _currentTrack = null;
        _isPlaying = false;
      } else if (removingCurrentTrack) {
        // If we removed the current track, play the next one
        _currentIndex = _currentIndex >= _queue.length ? 0 : _currentIndex;
        _currentTrack = _queue[_currentIndex];
      } else if (index < _currentIndex) {
        // Adjust current index if we removed a track before it
        _currentIndex--;
      }

      notifyListeners();
    }
  }

  void playNext() {
    if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
      _currentIndex++;
      _currentTrack = _queue[_currentIndex];
      _isPlaying = true;
      notifyListeners();
    }
  }

  void playPrevious() {
    if (_queue.isNotEmpty && _currentIndex > 0) {
      _currentIndex--;
      _currentTrack = _queue[_currentIndex];
      _isPlaying = true;
      notifyListeners();
    }
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = -1;
    _currentTrack = null;
    _isPlaying = false;
    notifyListeners();
  }
}
