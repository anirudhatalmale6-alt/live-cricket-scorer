import 'player.dart';

/// Represents a cricket team
class Team {
  final String id;
  final String name;
  final String? logoUrl;
  final String? shortName;
  List<Player> players;

  Team({
    required this.id,
    required this.name,
    this.logoUrl,
    this.shortName,
    List<Player>? players,
  }) : players = players ?? [];

  /// Get team's short name or first 3 letters
  String get displayShortName => shortName ?? name.substring(0, name.length >= 3 ? 3 : name.length).toUpperCase();

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logoUrl': logoUrl,
    'shortName': shortName,
    'players': players.map((p) => p.toJson()).toList(),
  };

  /// Create from JSON
  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'],
    name: json['name'],
    logoUrl: json['logoUrl'],
    shortName: json['shortName'],
    players: (json['players'] as List<dynamic>?)
        ?.map((p) => Player.fromJson(p))
        .toList() ?? [],
  );

  /// Create a copy with updated fields
  Team copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? shortName,
    List<Player>? players,
  }) => Team(
    id: id ?? this.id,
    name: name ?? this.name,
    logoUrl: logoUrl ?? this.logoUrl,
    shortName: shortName ?? this.shortName,
    players: players ?? List.from(this.players),
  );
}
