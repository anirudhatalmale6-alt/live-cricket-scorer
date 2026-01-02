import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/live_score_service.dart';
import 'providers/match_provider.dart';
import 'providers/team_provider.dart';
import 'screens/screens.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();

  // Initialize live score service
  final liveScoreService = LiveScoreService();

  runApp(
    LiveCricketScorerApp(
      storageService: storageService,
      liveScoreService: liveScoreService,
    ),
  );
}

/// Main application widget
class LiveCricketScorerApp extends StatelessWidget {
  final StorageService storageService;
  final LiveScoreService liveScoreService;

  const LiveCricketScorerApp({
    super.key,
    required this.storageService,
    required this.liveScoreService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Team provider for managing teams and players
        ChangeNotifierProvider(
          create: (_) => TeamProvider(storageService: storageService)
            ..loadData(),
        ),
        // Match provider for managing matches with live scoring
        ChangeNotifierProvider(
          create: (_) => MatchProvider(
            storageService: storageService,
            liveScoreService: liveScoreService,
          )..loadMatches(),
        ),
      ],
      child: MaterialApp(
        title: 'Live Cricket Scorer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
