import 'ball_event.dart';

/// Represents an innings in a cricket match
class Innings {
  final int inningsNumber;
  final String battingTeamId;
  final String bowlingTeamId;
  int totalRuns;
  int wickets;
  int overs;
  int balls;
  int extras;
  int wides;
  int noBalls;
  int byes;
  int legByes;
  bool isCompleted;
  bool isDeclared;
  List<BallEvent> ballEvents;
  List<BatsmanScore> batsmanScores;
  List<BowlerStats> bowlerStats;
  String? currentBatsmanId;
  String? nonStrikerId;
  String? currentBowlerId;

  Innings({
    required this.inningsNumber,
    required this.battingTeamId,
    required this.bowlingTeamId,
    this.totalRuns = 0,
    this.wickets = 0,
    this.overs = 0,
    this.balls = 0,
    this.extras = 0,
    this.wides = 0,
    this.noBalls = 0,
    this.byes = 0,
    this.legByes = 0,
    this.isCompleted = false,
    this.isDeclared = false,
    List<BallEvent>? ballEvents,
    List<BatsmanScore>? batsmanScores,
    List<BowlerStats>? bowlerStats,
    this.currentBatsmanId,
    this.nonStrikerId,
    this.currentBowlerId,
  })  : ballEvents = ballEvents ?? [],
        batsmanScores = batsmanScores ?? [],
        bowlerStats = bowlerStats ?? [];

  /// Get formatted overs display (e.g., "12.4")
  String get oversDisplay => '$overs.$balls';

  /// Get total balls bowled
  int get totalBalls => (overs * 6) + balls;

  /// Calculate current run rate
  double get runRate {
    final totalOvers = overs + (balls / 6);
    return totalOvers > 0 ? totalRuns / totalOvers : 0.0;
  }

  /// Get current over balls as list of display text
  List<String> get currentOverBalls {
    return ballEvents
        .where((b) => b.overNumber == overs)
        .map((b) => b.displayText)
        .toList();
  }

  /// Add a ball event and update statistics
  void addBallEvent(BallEvent event) {
    ballEvents.add(event);

    // Update runs
    totalRuns += event.totalRuns;

    // Update extras
    if (event.extraType != null) {
      extras += event.extraRuns;
      switch (event.extraType!) {
        case ExtraType.wide:
          wides += event.extraRuns;
          break;
        case ExtraType.noBall:
          noBalls += event.extraRuns;
          break;
        case ExtraType.bye:
          byes += event.extraRuns;
          break;
        case ExtraType.legBye:
          legByes += event.extraRuns;
          break;
      }
    }

    // Update wickets
    if (event.isWicket) {
      wickets++;
    }

    // Update balls/overs for legal deliveries
    if (event.isLegalDelivery) {
      balls++;
      if (balls >= 6) {
        overs++;
        balls = 0;
        // Rotate strike at end of over
        final temp = currentBatsmanId;
        currentBatsmanId = nonStrikerId;
        nonStrikerId = temp;
      }
    }

    // Rotate strike on odd runs
    if (event.runs % 2 == 1) {
      final temp = currentBatsmanId;
      currentBatsmanId = nonStrikerId;
      nonStrikerId = temp;
    }

    // Update batsman score
    _updateBatsmanScore(event);

    // Update bowler stats
    _updateBowlerStats(event);
  }

  void _updateBatsmanScore(BallEvent event) {
    var score = batsmanScores.firstWhere(
      (s) => s.playerId == event.batsmanId,
      orElse: () {
        final newScore = BatsmanScore(playerId: event.batsmanId);
        batsmanScores.add(newScore);
        return newScore;
      },
    );

    // Only count runs off bat (not byes/leg byes)
    if (event.extraType != ExtraType.bye && event.extraType != ExtraType.legBye) {
      score.runs += event.runs;
    }

    // Count balls faced for legal deliveries (except wides)
    if (event.isLegalDelivery || event.extraType == ExtraType.noBall) {
      score.ballsFaced++;
    }

    if (event.runs == 4) score.fours++;
    if (event.runs == 6) score.sixes++;

    if (event.isWicket && event.dismissedPlayerId == event.batsmanId) {
      score.isOut = true;
      score.wicketType = event.wicketType;
      score.bowlerId = event.bowlerId;
      score.fielderId = event.fielderId;
    }
  }

  void _updateBowlerStats(BallEvent event) {
    var stats = bowlerStats.firstWhere(
      (s) => s.playerId == event.bowlerId,
      orElse: () {
        final newStats = BowlerStats(playerId: event.bowlerId);
        bowlerStats.add(newStats);
        return newStats;
      },
    );

    stats.runsConceded += event.totalRuns;

    if (event.isLegalDelivery) {
      stats.balls++;
      if (stats.balls >= 6) {
        stats.overs++;
        stats.balls = 0;
        // Check for maiden over
        if (stats.runsThisOver == 0) {
          stats.maidens++;
        }
        stats.runsThisOver = 0;
      }
      stats.runsThisOver += event.totalRuns;
    }

    if (event.isWicket && event.wicketType != WicketType.runOut) {
      stats.wickets++;
    }

    if (event.extraType == ExtraType.wide) stats.wides++;
    if (event.extraType == ExtraType.noBall) stats.noBalls++;
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
    'inningsNumber': inningsNumber,
    'battingTeamId': battingTeamId,
    'bowlingTeamId': bowlingTeamId,
    'totalRuns': totalRuns,
    'wickets': wickets,
    'overs': overs,
    'balls': balls,
    'extras': extras,
    'wides': wides,
    'noBalls': noBalls,
    'byes': byes,
    'legByes': legByes,
    'isCompleted': isCompleted,
    'isDeclared': isDeclared,
    'ballEvents': ballEvents.map((b) => b.toJson()).toList(),
    'batsmanScores': batsmanScores.map((s) => s.toJson()).toList(),
    'bowlerStats': bowlerStats.map((s) => s.toJson()).toList(),
    'currentBatsmanId': currentBatsmanId,
    'nonStrikerId': nonStrikerId,
    'currentBowlerId': currentBowlerId,
  };

  /// Create from JSON
  factory Innings.fromJson(Map<String, dynamic> json) => Innings(
    inningsNumber: json['inningsNumber'],
    battingTeamId: json['battingTeamId'],
    bowlingTeamId: json['bowlingTeamId'],
    totalRuns: json['totalRuns'] ?? 0,
    wickets: json['wickets'] ?? 0,
    overs: json['overs'] ?? 0,
    balls: json['balls'] ?? 0,
    extras: json['extras'] ?? 0,
    wides: json['wides'] ?? 0,
    noBalls: json['noBalls'] ?? 0,
    byes: json['byes'] ?? 0,
    legByes: json['legByes'] ?? 0,
    isCompleted: json['isCompleted'] ?? false,
    isDeclared: json['isDeclared'] ?? false,
    ballEvents: (json['ballEvents'] as List<dynamic>?)
        ?.map((b) => BallEvent.fromJson(b))
        .toList() ?? [],
    batsmanScores: (json['batsmanScores'] as List<dynamic>?)
        ?.map((s) => BatsmanScore.fromJson(s))
        .toList() ?? [],
    bowlerStats: (json['bowlerStats'] as List<dynamic>?)
        ?.map((s) => BowlerStats.fromJson(s))
        .toList() ?? [],
    currentBatsmanId: json['currentBatsmanId'],
    nonStrikerId: json['nonStrikerId'],
    currentBowlerId: json['currentBowlerId'],
  );
}

/// Batsman score in an innings
class BatsmanScore {
  final String playerId;
  int runs;
  int ballsFaced;
  int fours;
  int sixes;
  bool isOut;
  WicketType? wicketType;
  String? bowlerId;
  String? fielderId;

  BatsmanScore({
    required this.playerId,
    this.runs = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.isOut = false,
    this.wicketType,
    this.bowlerId,
    this.fielderId,
  });

  double get strikeRate => ballsFaced > 0 ? (runs / ballsFaced) * 100 : 0.0;

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'runs': runs,
    'ballsFaced': ballsFaced,
    'fours': fours,
    'sixes': sixes,
    'isOut': isOut,
    'wicketType': wicketType?.name,
    'bowlerId': bowlerId,
    'fielderId': fielderId,
  };

  factory BatsmanScore.fromJson(Map<String, dynamic> json) => BatsmanScore(
    playerId: json['playerId'],
    runs: json['runs'] ?? 0,
    ballsFaced: json['ballsFaced'] ?? 0,
    fours: json['fours'] ?? 0,
    sixes: json['sixes'] ?? 0,
    isOut: json['isOut'] ?? false,
    wicketType: json['wicketType'] != null
        ? WicketType.values.firstWhere((w) => w.name == json['wicketType'])
        : null,
    bowlerId: json['bowlerId'],
    fielderId: json['fielderId'],
  );
}

/// Bowler statistics in an innings
class BowlerStats {
  final String playerId;
  int overs;
  int balls;
  int maidens;
  int runsConceded;
  int wickets;
  int wides;
  int noBalls;
  int runsThisOver;

  BowlerStats({
    required this.playerId,
    this.overs = 0,
    this.balls = 0,
    this.maidens = 0,
    this.runsConceded = 0,
    this.wickets = 0,
    this.wides = 0,
    this.noBalls = 0,
    this.runsThisOver = 0,
  });

  String get oversDisplay => '$overs.$balls';

  double get economy {
    final totalOvers = overs + (balls / 6);
    return totalOvers > 0 ? runsConceded / totalOvers : 0.0;
  }

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'overs': overs,
    'balls': balls,
    'maidens': maidens,
    'runsConceded': runsConceded,
    'wickets': wickets,
    'wides': wides,
    'noBalls': noBalls,
    'runsThisOver': runsThisOver,
  };

  factory BowlerStats.fromJson(Map<String, dynamic> json) => BowlerStats(
    playerId: json['playerId'],
    overs: json['overs'] ?? 0,
    balls: json['balls'] ?? 0,
    maidens: json['maidens'] ?? 0,
    runsConceded: json['runsConceded'] ?? 0,
    wickets: json['wickets'] ?? 0,
    wides: json['wides'] ?? 0,
    noBalls: json['noBalls'] ?? 0,
    runsThisOver: json['runsThisOver'] ?? 0,
  );
}
