import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/track.dart';
import '../providers/player_provider.dart';
import '../repositories/youtube_music_repository.dart';
import '../widgets/track_tile.dart';
import 'full_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final YouTubeMusicRepository _repository = YouTubeMusicRepository();
  bool _isLoading = true;
  String? _error;
  List<Track> _recommendations = [];
  List<Track> _featuredTracks = [];

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final recommendations = await _repository.getRecommendations();
      
      // Get the first 5 tracks as featured
      final featuredTracks = recommendations.take(5).toList();
      
      setState(() {
        _recommendations = recommendations;
        _featuredTracks = featuredTracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load recommendations: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isTabletOrDesktop = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRecommendations,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchRecommendations,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildContent(isTabletOrDesktop, constraints);
        },
      ),
    );
  }

  Widget _buildContent(bool isTabletOrDesktop, BoxConstraints constraints) {
    // Create responsive layout based on screen width
    return RefreshIndicator(
      onRefresh: _fetchRecommendations,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildFeatured(isTabletOrDesktop, constraints.maxWidth),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recommended for You',
                style: TextStyle(
                  fontSize: isTabletOrDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildRecommendations(isTabletOrDesktop),
            // Add extra bottom padding to account for mini player
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatured(bool isTabletOrDesktop, double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Featured Tracks',
            style: TextStyle(
              fontSize: isTabletOrDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        CarouselSlider(
          options: CarouselOptions(
            height: isTabletOrDesktop ? 280 : 220,
            viewportFraction: isTabletOrDesktop ? 0.4 : 0.8,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
          ),
          items: _featuredTracks.map((track) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => _playTrack(track),
                  child: Container(
                    width: maxWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image
                          Image.network(
                            track.albumArtUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.music_note, size: 64, color: Colors.white),
                              );
                            },
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          // Text overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    style: TextStyle(
                                      fontSize: isTabletOrDesktop ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    track.artist,
                                    style: TextStyle(
                                      fontSize: isTabletOrDesktop ? 16 : 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Play indicator
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Consumer<PlayerProvider>(
                              builder: (context, provider, child) {
                                final isPlaying = provider.currentTrack?.id == track.id;
                                if (!isPlaying) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_arrow, size: 16, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('Now Playing', style: TextStyle(fontSize: 12, color: Colors.white)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendations(bool isTabletOrDesktop) {
    // For tablet/desktop, use a grid layout
    if (isTabletOrDesktop) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _recommendations.length,
          itemBuilder: (context, index) {
            final track = _recommendations[index];
            return TrackTile(
              track: track,
              onTap: () => _playTrack(track),
              isPlaying: Provider.of<PlayerProvider>(context).currentTrack?.id == track.id,
            );
          },
        ),
      );
    }
    
    // For mobile, use a list layout
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final track = _recommendations[index];
        return TrackTile(
          track: track,
          onTap: () => _playTrack(track),
          isPlaying: Provider.of<PlayerProvider>(context).currentTrack?.id == track.id,
        );
      },
    );
  }

  void _playTrack(Track track) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.play(track);
    
    // Navigate to full player screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FullPlayerScreen(),
      ),
    );
  }
} 