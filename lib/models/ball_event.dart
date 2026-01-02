/// Represents a single ball/delivery in a cricket match
class BallEvent {
  final String id;
  final String matchId;
  final int inningsNumber;
  final int overNumber;
  final int ballNumber;
  final String batsmanId;
  final String bowlerId;
  final int runs;
  final bool isWicket;
  final WicketType? wicketType;
  final String? dismissedPlayerId;
  final String? fielderId;
  final ExtraType? extraType;
  final int extraRuns;
  final DateTime timestamp;
  final String? commentary;

  BallEvent({
    required this.id,
    required this.matchId,
    required this.inningsNumber,
    required this.overNumber,
    required this.ballNumber,
    required this.batsmanId,
    required this.bowlerId,
    this.runs = 0,
    this.isWicket = false,
    this.wicketType,
    this.dismissedPlayerId,
    this.fielderId,
    this.extraType,
    this.extraRuns = 0,
    DateTime? timestamp,
    this.commentary,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Total runs from this ball (including extras)
  int get totalRuns => runs + extraRuns;

  /// Check if this is an extra delivery (wide/no-ball)
  bool get isExtraDelivery =>
      extraType == ExtraType.wide || extraType == ExtraType.noBall;

  /// Check if this is a legal delivery
  bool get isLegalDelivery => !isExtraDelivery;

  /// Get display text for this ball
  String get displayText {
    if (isWicket) return 'W';
    if (extraType == ExtraType.wide) return 'Wd${extraRuns > 1 ? "+${extraRuns - 1}" : ""}';
    if (extraType == ExtraType.noBall) return 'Nb${runs > 0 ? "+$runs" : ""}';
    if (extraType == ExtraType.bye) return '${runs}b';
    if (extraType == ExtraType.legBye) return '${runs}lb';
    if (runs == 0) return '•';
    if (runs == 4) return '4';
    if (runs == 6) return '6';
    return runs.toString();
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
    'id': id,
    'matchId': matchId,
    'inningsNumber': inningsNumber,
    'overNumber': overNumber,
    'ballNumber': ballNumber,
    'batsmanId': batsmanId,
    'bowlerId': bowlerId,
    'runs': runs,
    'isWicket': isWicket,
    'wicketType': wicketType?.name,
    'dismissedPlayerId': dismissedPlayerId,
    'fielderId': fielderId,
    'extraType': extraType?.name,
    'extraRuns': extraRuns,
    'timestamp': timestamp.toIso8601String(),
    'commentary': commentary,
  };

  /// Create from JSON
  factory BallEvent.fromJson(Map<String, dynamic> json) => BallEvent(
    id: json['id'],
    matchId: json['matchId'],
    inningsNumber: json['inningsNumber'],
    overNumber: json['overNumber'],
    ballNumber: json['ballNumber'],
    batsmanId: json['batsmanId'],
    bowlerId: json['bowlerId'],
    runs: json['runs'] ?? 0,
    isWicket: json['isWicket'] ?? false,
    wicketType: json['wicketType'] != null
        ? WicketType.values.firstWhere((w) => w.name == json['wicketType'])
        : null,
    dismissedPlayerId: json['dismissedPlayerId'],
    fielderId: json['fielderId'],
    extraType: json['extraType'] != null
        ? ExtraType.values.firstWhere((e) => e.name == json['extraType'])
        : null,
    extraRuns: json['extraRuns'] ?? 0,
    timestamp: DateTime.parse(json['timestamp']),
    commentary: json['commentary'],
  );
}

/// Types of wickets in cricket
enum WicketType {
  bowled,
  caught,
  lbw,
  runOut,
  stumped,
  hitWicket,
  handledBall,
  obstructingField,
  timedOut,
  retired,
}

/// Types of extras in cricket
enum ExtraType {
  wide,
  noBall,
  bye,
  legBye,
}
