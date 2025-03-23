import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CreateMusicScreen extends StatefulWidget {
  const CreateMusicScreen({Key? key}) : super(key: key);

  @override
  State<CreateMusicScreen> createState() => _CreateMusicScreenState();
}

class _CreateMusicScreenState extends State<CreateMusicScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  String _generatedUrl = '';
  String _errorMessage = '';
  final Dio _dio = Dio();
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateMusic() async {
    if (_promptController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a prompt to generate music';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = '';
      _generatedUrl = '';
    });

    try {
      final response = await _dio.post(
        '$_baseUrl/api/ai/generate-music',
        data: {
          'prompt': _promptController.text,
          'duration': 30, // 30 seconds by default
        },
      );

      if (response.statusCode == 200) {
        // In a real implementation, this would handle the generated music URL
        setState(() {
          _isGenerating = false;
          _generatedUrl = response.data['streamUrl'] ?? '';
          if (_generatedUrl.isEmpty) {
            _errorMessage = 'Music generation API is not fully implemented yet';
          }
        });
      } else {
        setState(() {
          _isGenerating = false;
          _errorMessage = 'Failed to generate music: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Music')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BevyBot Assistant
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.music_note,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'BevyBot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tell me what kind of music you want me to create! Try "Create an upbeat jazz track with piano" or "Make a relaxing ambient soundscape with nature sounds".',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Prompt input
              TextField(
                controller: _promptController,
                decoration: InputDecoration(
                  hintText: 'Describe the music you want to create...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Generation button
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
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text('Creating your music...'),
                            ],
                          )
                          : const Text('CREATE MUSIC'),
                ),
              ),

              // Error message
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],

              // Generated music player (in a real app, this would be an audio player)
              if (_generatedUrl.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Generated Music',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_filled),
                            onPressed: () {
                              // Play the generated music
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Generated from "${_promptController.text}"',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: 0.0,
                                  backgroundColor: Colors.grey.shade800,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Features explanation
              const SizedBox(height: 32),
              const Text(
                'What BevyBot Can Create',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),

              // Feature Cards
              Column(
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.music_note,
                    title: 'Music Tracks',
                    description:
                        'Generate complete songs with different instruments and styles.',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.playlist_play,
                    title: 'Smart Playlists',
                    description:
                        'Ask BevyBot to create custom playlists based on your mood or preferences.',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureCard(
                    context,
                    icon: Icons.loop,
                    title: 'Loop Patterns',
                    description:
                        'Create repeatable loops for beats and backing tracks.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
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
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
