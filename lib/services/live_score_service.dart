import 'dart:async';
import '../models/models.dart';

/// Service for real-time score updates using streams
class LiveScoreService {
  // Stream controllers for different event types
  final _matchUpdateController = StreamController<CricketMatch>.broadcast();
  final _ballEventController = StreamController<BallEvent>.broadcast();
  final _inningsUpdateController = StreamController<Innings>.broadcast();

  // Expose streams for subscribers
  Stream<CricketMatch> get matchUpdates => _matchUpdateController.stream;
  Stream<BallEvent> get ballEvents => _ballEventController.stream;
  Stream<Innings> get inningsUpdates => _inningsUpdateController.stream;

  // Active match tracking
  CricketMatch? _activeMatch;
  CricketMatch? get activeMatch => _activeMatch;

  /// Set the active match for scoring
  void setActiveMatch(CricketMatch match) {
    _activeMatch = match;
    _matchUpdateController.add(match);
  }

  /// Record a ball event
  void recordBall({
    required int runs,
    bool isWicket = false,
    WicketType? wicketType,
    String? dismissedPlayerId,
    String? fielderId,
    ExtraType? extraType,
    int extraRuns = 0,
  }) {
    if (_activeMatch == null || _activeMatch!.currentInnings == null) return;

    final innings = _activeMatch!.currentInnings!;

    // Create ball event
    final ballEvent = BallEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      matchId: _activeMatch!.id,
      inningsNumber: innings.inningsNumber,
      overNumber: innings.overs,
      ballNumber: innings.balls,
      batsmanId: innings.currentBatsmanId ?? '',
      bowlerId: innings.currentBowlerId ?? '',
      runs: runs,
      isWicket: isWicket,
      wicketType: wicketType,
      dismissedPlayerId: dismissedPlayerId,
      fielderId: fielderId,
      extraType: extraType,
      extraRuns: extraRuns,
    );

    // Add to innings
    innings.addBallEvent(ballEvent);

    // Emit events
    _ballEventController.add(ballEvent);
    _inningsUpdateController.add(innings);
    _matchUpdateController.add(_activeMatch!);

    // Check for innings/match end conditions
    _checkMatchState();
  }

  /// Check if innings or match should end
  void _checkMatchState() {
    if (_activeMatch == null) return;

    final innings = _activeMatch!.currentInnings;
    if (innings == null) return;

    // Check all out
    if (innings.wickets >= 10) {
      innings.isCompleted = true;
      _handleInningsComplete();
      return;
    }

    // Check overs complete (for limited overs)
    if (_activeMatch!.format != MatchFormat.test) {
      if (innings.overs >= _activeMatch!.totalOvers) {
        innings.isCompleted = true;
        _handleInningsComplete();
        return;
      }
    }

    // Check if target achieved (second innings)
    if (innings.inningsNumber == 2) {
      final target = _activeMatch!.target;
      if (target != null && innings.totalRuns >= target) {
        innings.isCompleted = true;
        _activeMatch!.endMatch();
        _matchUpdateController.add(_activeMatch!);
      }
    }
  }

  /// Handle innings completion
  void _handleInningsComplete() {
    if (_activeMatch == null) return;

    final completedInnings = _activeMatch!.currentInnings;
    if (completedInnings == null) return;

    if (completedInnings.inningsNumber == 1) {
      // Start second innings
      _activeMatch!.startSecondInnings();
    } else {
      // Match complete
      _activeMatch!.endMatch();
    }

    _matchUpdateController.add(_activeMatch!);
  }

  /// Set current batsmen
  void setCurrentBatsmen(String strikerId, String nonStrikerId) {
    if (_activeMatch?.currentInnings == null) return;

    _activeMatch!.currentInnings!.currentBatsmanId = strikerId;
    _activeMatch!.currentInnings!.nonStrikerId = nonStrikerId;
    _matchUpdateController.add(_activeMatch!);
  }

  /// Set current bowler
  void setCurrentBowler(String bowlerId) {
    if (_activeMatch?.currentInnings == null) return;

    _activeMatch!.currentInnings!.currentBowlerId = bowlerId;
    _matchUpdateController.add(_activeMatch!);
  }

  /// Swap batsmen (rotate strike manually)
  void swapBatsmen() {
    if (_activeMatch?.currentInnings == null) return;

    final innings = _activeMatch!.currentInnings!;
    final temp = innings.currentBatsmanId;
    innings.currentBatsmanId = innings.nonStrikerId;
    innings.nonStrikerId = temp;
    _matchUpdateController.add(_activeMatch!);
  }

  /// Replace dismissed batsman
  void replaceBatsman(String newBatsmanId) {
    if (_activeMatch?.currentInnings == null) return;

    // Find which batsman is out and replace
    final innings = _activeMatch!.currentInnings!;
    final lastBall = innings.ballEvents.lastOrNull;

    if (lastBall?.isWicket == true) {
      if (lastBall?.dismissedPlayerId == innings.currentBatsmanId) {
        innings.currentBatsmanId = newBatsmanId;
      } else if (lastBall?.dismissedPlayerId == innings.nonStrikerId) {
        innings.nonStrikerId = newBatsmanId;
      }
    }

    _matchUpdateController.add(_activeMatch!);
  }

  /// Undo last ball
  void undoLastBall() {
    if (_activeMatch?.currentInnings == null) return;

    final innings = _activeMatch!.currentInnings!;
    if (innings.ballEvents.isEmpty) return;

    final lastBall = innings.ballEvents.removeLast();

    // Reverse the statistics
    innings.totalRuns -= lastBall.totalRuns;

    if (lastBall.extraType != null) {
      innings.extras -= lastBall.extraRuns;
      switch (lastBall.extraType!) {
        case ExtraType.wide:
          innings.wides -= lastBall.extraRuns;
          break;
        case ExtraType.noBall:
          innings.noBalls -= lastBall.extraRuns;
          break;
        case ExtraType.bye:
          innings.byes -= lastBall.extraRuns;
          break;
        case ExtraType.legBye:
          innings.legByes -= lastBall.extraRuns;
          break;
      }
    }

    if (lastBall.isWicket) {
      innings.wickets--;
    }

    if (lastBall.isLegalDelivery) {
      if (innings.balls == 0) {
        innings.overs--;
        innings.balls = 5;
      } else {
        innings.balls--;
      }
    }

    // Reverse strike rotation if needed
    if (lastBall.runs % 2 == 1) {
      final temp = innings.currentBatsmanId;
      innings.currentBatsmanId = innings.nonStrikerId;
      innings.nonStrikerId = temp;
    }

    _matchUpdateController.add(_activeMatch!);
  }

  /// Declare innings (Test matches)
  void declareInnings() {
    if (_activeMatch?.currentInnings == null) return;

    final innings = _activeMatch!.currentInnings!;
    innings.isDeclared = true;
    innings.isCompleted = true;

    _handleInningsComplete();
  }

  /// End match (abandoned, postponed, etc.)
  void endMatch(MatchStatus status, {String? result}) {
    if (_activeMatch == null) return;

    _activeMatch!.status = status;
    _activeMatch!.result = result;
    _activeMatch!.endTime = DateTime.now();

    _matchUpdateController.add(_activeMatch!);
  }

  /// Dispose streams
  void dispose() {
    _matchUpdateController.close();
    _ballEventController.close();
    _inningsUpdateController.close();
  }
}
