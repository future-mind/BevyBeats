import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';

/// A widget that handles keyboard shortcuts for playback control and other functions
/// This is particularly useful for desktop platforms where keyboard interaction is common
class KeyboardShortcutsHandler extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const KeyboardShortcutsHandler({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<KeyboardShortcutsHandler> createState() => _KeyboardShortcutsHandlerState();
}

class _KeyboardShortcutsHandlerState extends State<KeyboardShortcutsHandler> {
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _focusNode = FocusNode();
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (!widget.enabled) return KeyEventResult.ignored;
    
    // Only respond to key down events to avoid duplicate triggers
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    
    // Process keyboard shortcuts
    if (event.logicalKey == LogicalKeyboardKey.space) {
      // Space bar: Toggle play/pause
      if (playerProvider.currentTrack != null) {
        playerProvider.togglePlayPause();
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      // Right arrow: Seek forward 10 seconds
      if (playerProvider.currentTrack != null) {
        playerProvider.seekForward(10);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      // Left arrow: Seek backward 10 seconds
      if (playerProvider.currentTrack != null) {
        playerProvider.seekBackward(10);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.keyN) {
      // N key: Next track
      if (playerProvider.currentTrack != null) {
        playerProvider.next();
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.keyP) {
      // P key: Previous track
      if (playerProvider.currentTrack != null) {
        playerProvider.previous();
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
      // M key: Mute/unmute
      if (playerProvider.currentTrack != null) {
        playerProvider.toggleMute();
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      // Up arrow: Volume up
      if (playerProvider.currentTrack != null) {
        playerProvider.setVolume((playerProvider.volume + 0.1).clamp(0.0, 1.0));
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // Down arrow: Volume down
      if (playerProvider.currentTrack != null) {
        playerProvider.setVolume((playerProvider.volume - 0.1).clamp(0.0, 1.0));
        return KeyEventResult.handled;
      }
    }
    
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: widget.child,
    );
  }
}

/// Extension methods to add volume control and seeking to PlayerProvider
extension PlayerProviderExtensions on PlayerProvider {
  void togglePlayPause() {
    if (isPlaying) {
      pause();
    } else {
      resume();
    }
  }
  
  void toggleMute() {
    if (volume > 0) {
      // Store current volume and mute
      _previousVolume = volume;
      setVolume(0);
    } else {
      // Restore previous volume
      setVolume(_previousVolume > 0 ? _previousVolume : 0.5);
    }
  }
  
  void seekForward(int seconds) {
    if (position != null && duration != null) {
      final newPosition = position! + Duration(seconds: seconds);
      if (newPosition < duration!) {
        seek(newPosition);
      } else {
        seek(duration!);
      }
    }
  }
  
  void seekBackward(int seconds) {
    if (position != null) {
      final newPosition = position! - Duration(seconds: seconds);
      if (newPosition > Duration.zero) {
        seek(newPosition);
      } else {
        seek(Duration.zero);
      }
    }
  }
  
  // Internal storage for previous volume before muting
  double _previousVolume = 0.5;
} 