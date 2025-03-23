import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

// App screens, providers, and services
import 'screens/splash_screen.dart';
import 'providers/player_provider.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Hive for local storage
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Setup audio background service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.bevybeats.channel.audio',
    androidNotificationChannelName: 'BevyBeats Audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BevyBeatsApp());
}

class BevyBeatsApp extends StatelessWidget {
  const BevyBeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: 'BevyBeats',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Dark theme for Spotify-like appearance
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF1DB954), // Spotify green
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1DB954),
            secondary: Color(0xFF1DB954),
            surface: Color(0xFF181818),
            background: Color(0xFF121212),
            error: Color(0xFFCF6679),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
            displayMedium: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
            displaySmall: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            titleLarge: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: TextStyle(fontFamily: 'Poppins'),
            bodyMedium: TextStyle(fontFamily: 'Poppins'),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
