import 'innings.dart';
import 'team.dart';

/// Represents a cricket match
class CricketMatch {
  final String id;
  final String title;
  final Team team1;
  final Team team2;
  final MatchFormat format;
  final int totalOvers;
  final String venue;
  final DateTime scheduledTime;
  MatchStatus status;
  String? tossWinnerId;
  TossDecision? tossDecision;
  List<Innings> innings;
  int currentInningsIndex;
  String? winnerId;
  String? result;
  DateTime? startTime;
  DateTime? endTime;

  CricketMatch({
    required this.id,
    required this.title,
    required this.team1,
    required this.team2,
    required this.format,
    required this.totalOvers,
    required this.venue,
    required this.scheduledTime,
    this.status = MatchStatus.scheduled,
    this.tossWinnerId,
    this.tossDecision,
    List<Innings>? innings,
    this.currentInningsIndex = 0,
    this.winnerId,
    this.result,
    this.startTime,
    this.endTime,
  }) : innings = innings ?? [];

  /// Get current innings
  Innings? get currentInnings =>
      innings.isNotEmpty && currentInningsIndex < innings.length
          ? innings[currentInningsIndex]
          : null;

  /// Get batting team for current innings
  Team? get battingTeam {
    final batting = currentInnings;
    if (batting == null) return null;
    return batting.battingTeamId == team1.id ? team1 : team2;
  }

  /// Get bowling team for current innings
  Team? get bowlingTeam {
    final batting = currentInnings;
    if (batting == null) return null;
    return batting.bowlingTeamId == team1.id ? team1 : team2;
  }

  /// Check if match is live
  bool get isLive => status == MatchStatus.inProgress;

  /// Check if match is completed
  bool get isCompleted => status == MatchStatus.completed;

  /// Get target score (for second innings)
  int? get target {
    if (innings.length < 2) return null;
    return innings[0].totalRuns + 1;
  }

  /// Get runs needed to win
  int? get runsNeeded {
    if (target == null || currentInnings == null) return null;
    return target! - currentInnings!.totalRuns;
  }

  /// Get balls remaining
  int? get ballsRemaining {
    if (currentInnings == null) return null;
    final totalBalls = totalOvers * 6;
    final ballsBowled = currentInnings!.totalBalls;
    return totalBalls - ballsBowled;
  }

  /// Get required run rate
  double? get requiredRunRate {
    final needed = runsNeeded;
    final remaining = ballsRemaining;
    if (needed == null || remaining == null || remaining == 0) return null;
    return (needed / remaining) * 6;
  }

  /// Start the match
  void startMatch(String tossWinner, TossDecision decision) {
    tossWinnerId = tossWinner;
    tossDecision = decision;
    status = MatchStatus.inProgress;
    startTime = DateTime.now();

    // Determine batting order based on toss
    String battingTeamId;
    String bowlingTeamId;

    if (decision == TossDecision.bat) {
      battingTeamId = tossWinner;
      bowlingTeamId = tossWinner == team1.id ? team2.id : team1.id;
    } else {
      bowlingTeamId = tossWinner;
      battingTeamId = tossWinner == team1.id ? team2.id : team1.id;
    }

    // Create first innings
    innings.add(Innings(
      inningsNumber: 1,
      battingTeamId: battingTeamId,
      bowlingTeamId: bowlingTeamId,
    ));
    currentInningsIndex = 0;
  }

  /// Start second innings
  void startSecondInnings() {
    if (innings.isEmpty) return;

    final firstInnings = innings[0];
    innings.add(Innings(
      inningsNumber: 2,
      battingTeamId: firstInnings.bowlingTeamId,
      bowlingTeamId: firstInnings.battingTeamId,
    ));
    currentInningsIndex = 1;
  }

  /// End the match
  void endMatch() {
    status = MatchStatus.completed;
    endTime = DateTime.now();

    // Determine winner and result
    if (innings.length >= 2) {
      final firstInningsRuns = innings[0].totalRuns;
      final secondInningsRuns = innings[1].totalRuns;
      final secondInningsWickets = innings[1].wickets;

      if (secondInningsRuns > firstInningsRuns) {
        winnerId = innings[1].battingTeamId;
        final wicketsLeft = 10 - secondInningsWickets;
        result = '${_getTeamName(winnerId!)} won by $wicketsLeft wickets';
      } else if (firstInningsRuns > secondInningsRuns) {
        winnerId = innings[0].battingTeamId;
        final runsDiff = firstInningsRuns - secondInningsRuns;
        result = '${_getTeamName(winnerId!)} won by $runsDiff runs';
      } else {
        result = 'Match Tied';
      }
    }
  }

  String _getTeamName(String teamId) {
    return teamId == team1.id ? team1.name : team2.name;
  }

  /// Get match summary text
  String get summaryText {
    if (status == MatchStatus.scheduled) {
      return 'Scheduled';
    }

    if (innings.isEmpty) return 'No data';

    final firstInnings = innings[0];
    final batting1 = firstInnings.battingTeamId == team1.id ? team1 : team2;
    String summary = '${batting1.displayShortName}: ${firstInnings.totalRuns}/${firstInnings.wickets} (${firstInnings.oversDisplay})';

    if (innings.length >= 2) {
      final secondInnings = innings[1];
      final batting2 = secondInnings.battingTeamId == team1.id ? team1 : team2;
      summary += '\n${batting2.displayShortName}: ${secondInnings.totalRuns}/${secondInnings.wickets} (${secondInnings.oversDisplay})';
    }

    if (result != null) {
      summary += '\n$result';
    }

    return summary;
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'team1': team1.toJson(),
    'team2': team2.toJson(),
    'format': format.name,
    'totalOvers': totalOvers,
    'venue': venue,
    'scheduledTime': scheduledTime.toIso8601String(),
    'status': status.name,
    'tossWinnerId': tossWinnerId,
    'tossDecision': tossDecision?.name,
    'innings': innings.map((i) => i.toJson()).toList(),
    'currentInningsIndex': currentInningsIndex,
    'winnerId': winnerId,
    'result': result,
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
  };

  /// Create from JSON
  factory CricketMatch.fromJson(Map<String, dynamic> json) => CricketMatch(
    id: json['id'],
    title: json['title'],
    team1: Team.fromJson(json['team1']),
    team2: Team.fromJson(json['team2']),
    format: MatchFormat.values.firstWhere((f) => f.name == json['format']),
    totalOvers: json['totalOvers'],
    venue: json['venue'],
    scheduledTime: DateTime.parse(json['scheduledTime']),
    status: MatchStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => MatchStatus.scheduled,
    ),
    tossWinnerId: json['tossWinnerId'],
    tossDecision: json['tossDecision'] != null
        ? TossDecision.values.firstWhere((t) => t.name == json['tossDecision'])
        : null,
    innings: (json['innings'] as List<dynamic>?)
        ?.map((i) => Innings.fromJson(i))
        .toList() ?? [],
    currentInningsIndex: json['currentInningsIndex'] ?? 0,
    winnerId: json['winnerId'],
    result: json['result'],
    startTime: json['startTime'] != null
        ? DateTime.parse(json['startTime'])
        : null,
    endTime: json['endTime'] != null
        ? DateTime.parse(json['endTime'])
        : null,
  );
}

/// Match formats
enum MatchFormat {
  t20,
  odi,
  test,
  t10,
  hundred,
  custom,
}

extension MatchFormatExtension on MatchFormat {
  String get displayName {
    switch (this) {
      case MatchFormat.t20:
        return 'T20';
      case MatchFormat.odi:
        return 'ODI (50 Overs)';
      case MatchFormat.test:
        return 'Test';
      case MatchFormat.t10:
        return 'T10';
      case MatchFormat.hundred:
        return 'The Hundred';
      case MatchFormat.custom:
        return 'Custom';
    }
  }

  int get defaultOvers {
    switch (this) {
      case MatchFormat.t20:
        return 20;
      case MatchFormat.odi:
        return 50;
      case MatchFormat.test:
        return 90; // Per day
      case MatchFormat.t10:
        return 10;
      case MatchFormat.hundred:
        return 20; // 100 balls ≈ 16.4 overs
      case MatchFormat.custom:
        return 20;
    }
  }
}

/// Match status
enum MatchStatus {
  scheduled,
  inProgress,
  completed,
  abandoned,
  postponed,
}

/// Toss decision
enum TossDecision {
  bat,
  bowl,
}
