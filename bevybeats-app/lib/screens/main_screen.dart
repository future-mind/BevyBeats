import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/create_music_screen.dart';
import '../providers/player_provider.dart';
import '../widgets/mini_player.dart';
import 'full_player_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    Placeholder(), // Library screen (to be implemented)
    CreateMusicScreen(),
  ];
  
  final List<String> _titles = [
    'Home',
    'Search',
    'Library',
    'Create'
  ];
  
  final List<IconData> _icons = [
    Icons.home,
    Icons.search,
    Icons.library_music,
    Icons.music_note,
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    if (isWideScreen) {
      // Tablet or desktop layout with side navigation
      return Scaffold(
        body: Row(
          children: [
            // Side navigation
            NavigationRail(
              extended: screenWidth > 1200,
              minExtendedWidth: 180,
              leading: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: screenWidth > 1200
                    ? const Text(
                        'BevyBeats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const FlutterLogo(size: 32),
              ),
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: List.generate(
                _titles.length,
                (index) => NavigationRailDestination(
                  icon: Icon(_icons[index]),
                  selectedIcon: Icon(_icons[index], color: Theme.of(context).colorScheme.primary),
                  label: Text(_titles[index]),
                ),
              ),
            ),
            
            // Divider
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            
            // Main content area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _screens[_currentIndex],
                  ),
                  // Mini player at the bottom
                  Consumer<PlayerProvider>(
                    builder: (context, provider, child) {
                      if (provider.currentTrack == null) {
                        return const SizedBox.shrink();
                      }
                      return const MiniPlayer();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile layout with bottom navigation
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Current screen
              _screens[_currentIndex],
              
              // Mini player above bottom navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: kBottomNavigationBarHeight + 8,
                child: Consumer<PlayerProvider>(
                  builder: (context, provider, child) {
                    if (provider.currentTrack == null) {
                      return const SizedBox.shrink();
                    }
                    return const MiniPlayer();
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'Library',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Create',
            ),
          ],
        ),
      );
    }
  }
} 