import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/player_provider.dart';
import '../models/track.dart';

class CreateMusicScreen extends StatefulWidget {
  const CreateMusicScreen({Key? key}) : super(key: key);

  @override
  State<CreateMusicScreen> createState() => _CreateMusicScreenState();
}

class _CreateMusicScreenState extends State<CreateMusicScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  String _error = '';
  Track? _generatedTrack;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateMusic() async {
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      setState(() {
        _error = 'Please enter a description of the music you want to create';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = '';
      _generatedTrack = null;
    });

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
      final dio = Dio();

      final response = await dio.post(
        '$baseUrl/api/ai/generate-music',
        data: {'prompt': prompt},
      );

      if (response.statusCode == 200 && response.data['track'] != null) {
        final trackData = response.data['track'];

        setState(() {
          _generatedTrack = Track(
            videoId:
                trackData['videoId'] ??
                'generated-${DateTime.now().millisecondsSinceEpoch}',
            title: trackData['title'] ?? 'Generated Music',
            artist: trackData['artist'] ?? 'BevyBot AI',
            thumbnailUrl:
                trackData['thumbnailUrl'] ?? 'https://via.placeholder.com/300',
            streamUrl: trackData['streamUrl'] ?? '',
            durationSeconds: trackData['durationSeconds'] ?? 180,
            duration: trackData['duration'] ?? '3:00',
          );
          _isGenerating = false;
        });
      } else {
        setState(() {
          _error = 'Failed to generate music: ${response.statusCode}';
          _isGenerating = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Music')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prompt input
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                hintText: 'Describe the music you want to create...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateMusic,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isGenerating
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 16),
                            Text('Generating...'),
                          ],
                        )
                        : const Text('Generate Music'),
              ),
            ),

            // Error message
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Generated music
            if (_generatedTrack != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Generated Music',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _generatedTrack!.thumbnailUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    _generatedTrack!.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _generatedTrack!.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_filled, size: 40),
                    onPressed: () {
                      if (_generatedTrack!.streamUrl.isNotEmpty) {
                        final playerProvider = Provider.of<PlayerProvider>(
                          context,
                          listen: false,
                        );
                        playerProvider.playTrack(_generatedTrack!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No audio available for this track'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],

            // Feature explanation
            const SizedBox(height: 32),
            const Text(
              'BevyBot Can Create',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Icons.music_note,
              title: 'Music Tracks',
              description:
                  'Create original music tracks based on your text descriptions',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.playlist_play,
              title: 'Smart Playlists',
              description:
                  'Generate playlists based on moods, activities, or themes',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.loop,
              title: 'Loop Patterns',
              description:
                  'Generate loopable beats perfect for sampling or backgrounds',
            ),
            const SizedBox(height: 80), // Space for mini-player
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
