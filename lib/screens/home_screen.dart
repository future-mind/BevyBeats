import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/track.dart';
import '../repositories/youtube_music_repository.dart';
import '../providers/player_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final YouTubeMusicRepository _repository = YouTubeMusicRepository();

  List<Track> _recommendedTracks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final recommendations = await _repository.getRecommendations();
      setState(() {
        _recommendedTracks = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load recommendations: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BevyBeats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
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
                      onPressed: _loadRecommendations,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadRecommendations,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured section with carousel
                      if (_recommendedTracks.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.8,
                            enlargeCenterPage: true,
                            autoPlay: true,
                          ),
                          items:
                              _recommendedTracks.take(5).map((track) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return GestureDetector(
                                      onTap: () {
                                        _playTrack(track);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(track.albumArt),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  track.title,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  track.artist,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                        ),
                      ],

                      // Recommended tracks section
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Recommended for You',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_recommendedTracks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text('No recommendations available'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recommendedTracks.length,
                          itemBuilder: (context, index) {
                            final track = _recommendedTracks[index];
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
                              trailing: IconButton(
                                icon: const Icon(Icons.play_circle_fill),
                                onPressed: () {
                                  _playTrack(track);
                                },
                              ),
                              onTap: () {
                                _playTrack(track);
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  void _playTrack(Track track) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.play(track);
  }
}
