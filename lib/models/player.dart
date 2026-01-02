/// Represents a cricket player with their statistics
class Player {
  final String id;
  final String name;
  final String teamId;
  final PlayerRole role;

  // Batting statistics
  int totalRuns;
  int ballsFaced;
  int fours;
  int sixes;
  int matchesPlayed;
  int innings;
  int notOuts;
  int highestScore;

  // Bowling statistics
  int wicketsTaken;
  int oversBowled;
  int ballsBowled;
  int runsConceded;
  int maidens;
  int bestBowlingWickets;
  int bestBowlingRuns;

  // Fielding statistics
  int catches;
  int runOuts;
  int stumpings;

  Player({
    required this.id,
    required this.name,
    required this.teamId,
    this.role = PlayerRole.allRounder,
    this.totalRuns = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.matchesPlayed = 0,
    this.innings = 0,
    this.notOuts = 0,
    this.highestScore = 0,
    this.wicketsTaken = 0,
    this.oversBowled = 0,
    this.ballsBowled = 0,
    this.runsConceded = 0,
    this.maidens = 0,
    this.bestBowlingWickets = 0,
    this.bestBowlingRuns = 0,
    this.catches = 0,
    this.runOuts = 0,
    this.stumpings = 0,
  });

  /// Calculate batting average
  double get battingAverage {
    final dismissals = innings - notOuts;
    return dismissals > 0 ? totalRuns / dismissals : totalRuns.toDouble();
  }

  /// Calculate strike rate
  double get strikeRate {
    return ballsFaced > 0 ? (totalRuns / ballsFaced) * 100 : 0.0;
  }

  /// Calculate bowling average
  double get bowlingAverage {
    return wicketsTaken > 0 ? runsConceded / wicketsTaken : 0.0;
  }

  /// Calculate economy rate
  double get economyRate {
    final totalOvers = oversBowled + (ballsBowled / 6);
    return totalOvers > 0 ? runsConceded / totalOvers : 0.0;
  }

  /// Calculate bowling strike rate
  double get bowlingStrikeRate {
    final totalBalls = (oversBowled * 6) + ballsBowled;
    return wicketsTaken > 0 ? totalBalls / wicketsTaken : 0.0;
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'teamId': teamId,
    'role': role.name,
    'totalRuns': totalRuns,
    'ballsFaced': ballsFaced,
    'fours': fours,
    'sixes': sixes,
    'matchesPlayed': matchesPlayed,
    'innings': innings,
    'notOuts': notOuts,
    'highestScore': highestScore,
    'wicketsTaken': wicketsTaken,
    'oversBowled': oversBowled,
    'ballsBowled': ballsBowled,
    'runsConceded': runsConceded,
    'maidens': maidens,
    'bestBowlingWickets': bestBowlingWickets,
    'bestBowlingRuns': bestBowlingRuns,
    'catches': catches,
    'runOuts': runOuts,
    'stumpings': stumpings,
  };

  /// Create from JSON
  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    teamId: json['teamId'],
    role: PlayerRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => PlayerRole.allRounder,
    ),
    totalRuns: json['totalRuns'] ?? 0,
    ballsFaced: json['ballsFaced'] ?? 0,
    fours: json['fours'] ?? 0,
    sixes: json['sixes'] ?? 0,
    matchesPlayed: json['matchesPlayed'] ?? 0,
    innings: json['innings'] ?? 0,
    notOuts: json['notOuts'] ?? 0,
    highestScore: json['highestScore'] ?? 0,
    wicketsTaken: json['wicketsTaken'] ?? 0,
    oversBowled: json['oversBowled'] ?? 0,
    ballsBowled: json['ballsBowled'] ?? 0,
    runsConceded: json['runsConceded'] ?? 0,
    maidens: json['maidens'] ?? 0,
    bestBowlingWickets: json['bestBowlingWickets'] ?? 0,
    bestBowlingRuns: json['bestBowlingRuns'] ?? 0,
    catches: json['catches'] ?? 0,
    runOuts: json['runOuts'] ?? 0,
    stumpings: json['stumpings'] ?? 0,
  );

  /// Create a copy with updated fields
  Player copyWith({
    String? id,
    String? name,
    String? teamId,
    PlayerRole? role,
    int? totalRuns,
    int? ballsFaced,
    int? fours,
    int? sixes,
    int? matchesPlayed,
    int? innings,
    int? notOuts,
    int? highestScore,
    int? wicketsTaken,
    int? oversBowled,
    int? ballsBowled,
    int? runsConceded,
    int? maidens,
    int? bestBowlingWickets,
    int? bestBowlingRuns,
    int? catches,
    int? runOuts,
    int? stumpings,
  }) => Player(
    id: id ?? this.id,
    name: name ?? this.name,
    teamId: teamId ?? this.teamId,
    role: role ?? this.role,
    totalRuns: totalRuns ?? this.totalRuns,
    ballsFaced: ballsFaced ?? this.ballsFaced,
    fours: fours ?? this.fours,
    sixes: sixes ?? this.sixes,
    matchesPlayed: matchesPlayed ?? this.matchesPlayed,
    innings: innings ?? this.innings,
    notOuts: notOuts ?? this.notOuts,
    highestScore: highestScore ?? this.highestScore,
    wicketsTaken: wicketsTaken ?? this.wicketsTaken,
    oversBowled: oversBowled ?? this.oversBowled,
    ballsBowled: ballsBowled ?? this.ballsBowled,
    runsConceded: runsConceded ?? this.runsConceded,
    maidens: maidens ?? this.maidens,
    bestBowlingWickets: bestBowlingWickets ?? this.bestBowlingWickets,
    bestBowlingRuns: bestBowlingRuns ?? this.bestBowlingRuns,
    catches: catches ?? this.catches,
    runOuts: runOuts ?? this.runOuts,
    stumpings: stumpings ?? this.stumpings,
  );
}

/// Player roles in cricket
enum PlayerRole {
  batsman,
  bowler,
  allRounder,
  wicketKeeper,
}
