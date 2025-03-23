import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../services/audio_service.dart';

class MiniPlayer extends StatelessWidget {
  final AudioService audioService;

  const MiniPlayer({Key? key, required this.audioService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        if (playerProvider.currentTrack == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            // Navigate to full player
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FullPlayerScreen()),
            );
          },
          child: Container(
            height: 60,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                // Album art
                Image.network(
                  playerProvider.currentTrack!.albumArt,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (ctx, error, stackTrace) => Container(
                        height: 60,
                        width: 60,
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.music_note),
                      ),
                ),

                // Track info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          playerProvider.currentTrack!.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          playerProvider.currentTrack!.artist,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // Previous track button
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    playerProvider.playPrevious();
                    if (playerProvider.currentTrack != null) {
                      audioService.playTrack(playerProvider.currentTrack!);
                    }
                  },
                ),

                // Play/Pause button
                IconButton(
                  icon: Icon(
                    playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    if (playerProvider.isPlaying) {
                      audioService.pause();
                      playerProvider.pause();
                    } else {
                      audioService.resume();
                      playerProvider.resume();
                    }
                  },
                ),

                // Next track button
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    playerProvider.playNext();
                    if (playerProvider.currentTrack != null) {
                      audioService.playTrack(playerProvider.currentTrack!);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// For navigation purposes - we'll implement this later
class FullPlayerScreen extends StatelessWidget {
  const FullPlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: const Center(child: Text('Full player coming soon')),
    );
  }
}
