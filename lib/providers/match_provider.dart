import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/live_score_service.dart';

/// Provider for match state management with real-time updates
class MatchProvider extends ChangeNotifier {
  final StorageService _storageService;
  final LiveScoreService _liveScoreService;

  List<CricketMatch> _matches = [];
  CricketMatch? _activeMatch;
  bool _isLoading = false;
  String? _error;

  StreamSubscription<CricketMatch>? _matchSubscription;

  MatchProvider({
    required StorageService storageService,
    required LiveScoreService liveScoreService,
  })  : _storageService = storageService,
        _liveScoreService = liveScoreService {
    _subscribeToUpdates();
  }

  // Getters
  List<CricketMatch> get matches => _matches;
  CricketMatch? get activeMatch => _activeMatch;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get scheduled matches
  List<CricketMatch> get scheduledMatches =>
      _matches.where((m) => m.status == MatchStatus.scheduled).toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

  /// Get live matches
  List<CricketMatch> get liveMatches =>
      _matches.where((m) => m.status == MatchStatus.inProgress).toList();

  /// Get completed matches
  List<CricketMatch> get completedMatches =>
      _matches.where((m) => m.status == MatchStatus.completed).toList()
        ..sort((a, b) => (b.endTime ?? b.scheduledTime)
            .compareTo(a.endTime ?? a.scheduledTime));

  /// Subscribe to live score updates
  void _subscribeToUpdates() {
    _matchSubscription = _liveScoreService.matchUpdates.listen((match) {
      _activeMatch = match;
      _updateMatchInList(match);
      notifyListeners();
    });
  }

  /// Load all matches from storage
  Future<void> loadMatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matches = await _storageService.loadMatches();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load matches: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new match
  Future<void> createMatch({
    required String title,
    required Team team1,
    required Team team2,
    required MatchFormat format,
    required int totalOvers,
    required String venue,
    required DateTime scheduledTime,
  }) async {
    final match = CricketMatch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      team1: team1,
      team2: team2,
      format: format,
      totalOvers: totalOvers,
      venue: venue,
      scheduledTime: scheduledTime,
    );

    _matches.add(match);
    await _storageService.saveMatch(match);
    notifyListeners();
  }

  /// Start a match (after toss)
  Future<void> startMatch(
    String matchId,
    String tossWinnerId,
    TossDecision decision,
  ) async {
    final match = _matches.firstWhere((m) => m.id == matchId);
    match.startMatch(tossWinnerId, decision);

    _activeMatch = match;
    _liveScoreService.setActiveMatch(match);

    await _storageService.saveMatch(match);
    notifyListeners();
  }

  /// Set active match for scoring
  void setActiveMatch(CricketMatch match) {
    _activeMatch = match;
    _liveScoreService.setActiveMatch(match);
    notifyListeners();
  }

  /// Record a ball
  Future<void> recordBall({
    required int runs,
    bool isWicket = false,
    WicketType? wicketType,
    String? dismissedPlayerId,
    String? fielderId,
    ExtraType? extraType,
    int extraRuns = 0,
  }) async {
    _liveScoreService.recordBall(
      runs: runs,
      isWicket: isWicket,
      wicketType: wicketType,
      dismissedPlayerId: dismissedPlayerId,
      fielderId: fielderId,
      extraType: extraType,
      extraRuns: extraRuns,
    );

    if (_activeMatch != null) {
      await _storageService.saveMatch(_activeMatch!);
    }
  }

  /// Set current batsmen
  void setCurrentBatsmen(String strikerId, String nonStrikerId) {
    _liveScoreService.setCurrentBatsmen(strikerId, nonStrikerId);
  }

  /// Set current bowler
  void setCurrentBowler(String bowlerId) {
    _liveScoreService.setCurrentBowler(bowlerId);
  }

  /// Swap batsmen
  void swapBatsmen() {
    _liveScoreService.swapBatsmen();
  }

  /// Replace batsman
  void replaceBatsman(String newBatsmanId) {
    _liveScoreService.replaceBatsman(newBatsmanId);
  }

  /// Undo last ball
  Future<void> undoLastBall() async {
    _liveScoreService.undoLastBall();

    if (_activeMatch != null) {
      await _storageService.saveMatch(_activeMatch!);
    }
  }

  /// Start second innings
  Future<void> startSecondInnings() async {
    if (_activeMatch != null) {
      _activeMatch!.startSecondInnings();
      await _storageService.saveMatch(_activeMatch!);
      notifyListeners();
    }
  }

  /// End match
  Future<void> endMatch(MatchStatus status, {String? result}) async {
    _liveScoreService.endMatch(status, result: result);

    if (_activeMatch != null) {
      await _storageService.saveMatch(_activeMatch!);
    }

    _activeMatch = null;
    notifyListeners();
  }

  /// Delete a match
  Future<void> deleteMatch(String matchId) async {
    _matches.removeWhere((m) => m.id == matchId);
    await _storageService.deleteMatch(matchId);
    notifyListeners();
  }

  /// Update match in list
  void _updateMatchInList(CricketMatch match) {
    final index = _matches.indexWhere((m) => m.id == match.id);
    if (index >= 0) {
      _matches[index] = match;
    }
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    super.dispose();
  }
}
