import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../screens/full_player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    final playerProvider = Provider.of<PlayerProvider>(context);
    final currentTrack = playerProvider.currentTrack;

    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FullPlayerScreen()),
        );
      },
      child: Container(
        height: 72,
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: isWideScreen ? screenWidth * 0.1 : 8.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Album Art
              Hero(
                tag: 'album_art',
                child: Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey[900],
                  child: Image.network(
                    currentTrack.albumArtUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.music_note,
                        size: 32,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),

              // Track Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentTrack.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentTrack.artist,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Progress bar only shown on wider screens
                      if (isWideScreen)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: StreamBuilder<Duration>(
                            stream: playerProvider.positionStream,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? Duration.zero;
                              final duration =
                                  playerProvider.duration ?? Duration.zero;

                              return LinearProgressIndicator(
                                value:
                                    duration.inMilliseconds > 0
                                        ? position.inMilliseconds /
                                            duration.inMilliseconds
                                        : 0.0,
                                backgroundColor: Colors.grey[700],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                                minHeight: 2,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous button (only on wider screens)
                  if (isWideScreen)
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 24),
                      onPressed: playerProvider.previous,
                      tooltip: 'Previous',
                    ),

                  // Play/Pause button
                  StreamBuilder<bool>(
                    stream: playerProvider.playingStream,
                    initialData: false,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                        onPressed:
                            isPlaying
                                ? playerProvider.pause
                                : playerProvider.resume,
                      );
                    },
                  ),

                  // Next button (only on wider screens)
                  if (isWideScreen)
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 24),
                      onPressed: playerProvider.next,
                      tooltip: 'Next',
                    ),

                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
