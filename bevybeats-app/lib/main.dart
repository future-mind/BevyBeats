import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/player_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/keyboard_shortcuts.dart';

// Import app screens and models - these will be created later
// import 'package:bevybeats/screens/splash_screen.dart';
// import 'package:bevybeats/providers/auth_provider.dart';
// import 'package:bevybeats/providers/music_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Just Audio Background
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // Set preferred orientations - different for mobile vs desktop
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Set system UI overlay style - mainly for mobile
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  runApp(const BevyBeatsApp());
}

class BevyBeatsApp extends StatelessWidget {
  const BevyBeatsApp({Key? key}) : super(key: key);

  bool get _isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  bool get _isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  bool get _isWeb => kIsWeb;
  bool get _isIOS => !kIsWeb && Platform.isIOS;
  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PlayerProvider())],
      child: MaterialApp(
        title: 'BevyBeats',
        debugShowCheckedModeBanner: false,
        theme: _getMaterialTheme(Brightness.light),
        darkTheme: _getMaterialTheme(Brightness.dark),
        themeMode: ThemeMode.dark,
        home: KeyboardShortcutsHandler(
          enabled: _isDesktop || _isWeb,
          child: const SplashScreen(),
        ),
      ),
    );
  }

  ThemeData _getMaterialTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Base theme
    ThemeData baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: brightness,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      brightness: brightness,
    );

    // Mobile-specific adjustments
    if (_isMobile) {
      baseTheme = baseTheme.copyWith(
        scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    // Desktop-specific adjustments
    if (_isDesktop) {
      baseTheme = baseTheme.copyWith(
        scaffoldBackgroundColor:
            isDark ? const Color(0xFF121212) : Colors.grey[50],
        // Desktop tends to need slightly larger touch targets and text
        textTheme: baseTheme.textTheme.copyWith(
          labelLarge: baseTheme.textTheme.labelLarge?.copyWith(fontSize: 15),
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 16),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
      );
    }

    // Web-specific adjustments
    if (_isWeb) {
      baseTheme = baseTheme.copyWith(
        // Web optimizations here if needed
      );
    }

    return baseTheme;
  }
}

// Temporary placeholder screen until we create actual screens
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1DB954), Color(0xFF121212)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BevyBeats',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Where Music Meets Magic',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  // Placeholder for navigation
                },
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
