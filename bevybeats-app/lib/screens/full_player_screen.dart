import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/track.dart';
import '../services/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class FullPlayerScreen extends StatelessWidget {
  const FullPlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Now Playing'),
      ),
      extendBodyBehindAppBar: true,
      body: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          final Track? currentTrack = playerProvider.currentTrack;

          if (currentTrack == null) {
            return const Center(child: Text('No track playing'));
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple.shade900, Colors.black],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Album Art
                    Hero(
                      tag: 'album-art-${currentTrack.videoId}',
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            currentTrack.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[900],
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 80,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Track Info
                    Text(
                      currentTrack.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentTrack.artist,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Progress Bar
                    StreamBuilder<AudioPositionData>(
                      stream: playerProvider.positionDataStream,
                      builder: (context, snapshot) {
                        final positionData =
                            snapshot.data ??
                            AudioPositionData(
                              position: Duration.zero,
                              bufferedPosition: Duration.zero,
                              duration: Duration.zero,
                            );

                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white.withOpacity(
                                  0.3,
                                ),
                                trackShape: const RoundedRectSliderTrackShape(),
                                trackHeight: 4.0,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8.0,
                                ),
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withOpacity(0.3),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16.0,
                                ),
                              ),
                              child: Slider(
                                value: positionData.position.inMilliseconds
                                    .toDouble()
                                    .clamp(
                                      0.0,
                                      positionData.duration.inMilliseconds
                                          .toDouble()
                                          .max(0.0),
                                    ),
                                min: 0.0,
                                max: positionData.duration.inMilliseconds
                                    .toDouble()
                                    .max(0.0),
                                onChanged: (value) {
                                  playerProvider.seek(
                                    Duration(milliseconds: value.round()),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(positionData.position),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(positionData.duration),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Playback Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shuffle, color: Colors.white),
                          onPressed: () {
                            // Shuffle functionality
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: playerProvider.skipToPrevious,
                        ),
                        StreamBuilder<PlayerState>(
                          stream: playerProvider.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final processingState =
                                playerState?.processingState;
                            final playing = playerState?.playing ?? false;

                            return IconButton(
                              icon: Icon(
                                playing
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: Colors.white,
                                size: 64,
                              ),
                              onPressed: playerProvider.togglePlayPause,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: playerProvider.skipToNext,
                        ),
                        IconButton(
                          icon: const Icon(Icons.repeat, color: Colors.white),
                          onPressed: () {
                            // Repeat functionality
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
