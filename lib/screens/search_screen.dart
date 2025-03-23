import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../repositories/youtube_music_repository.dart';
import '../providers/player_provider.dart';
import '../services/audio_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final YouTubeMusicRepository _repository = YouTubeMusicRepository();
  final AudioService _audioService = AudioService();

  List<Track> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _repository.search(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search songs, artists, albums...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchResults = [];
                  _errorMessage = '';
                });
              },
            ),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _performSearch(_searchController.text);
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _performSearch(_searchController.text),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _searchResults.isEmpty
              ? const Center(child: Text('Search for your favorite music'))
              : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final track = _searchResults[index];
                  return ListTile(
                    leading: Image.network(
                      track.albumArt,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (ctx, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.music_note),
                          ),
                    ),
                    title: Text(track.title),
                    subtitle: Text(track.artist),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_circle_fill),
                          onPressed: () {
                            _playTrack(track);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.playlist_add),
                          onPressed: () {
                            _addToQueue(track);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      _playTrack(track);
                    },
                  );
                },
              ),
    );
  }

  void _playTrack(Track track) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.play(track);
    _audioService.playTrack(track);
  }

  void _addToQueue(Track track) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.addToQueue(track);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${track.title}" to queue'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
