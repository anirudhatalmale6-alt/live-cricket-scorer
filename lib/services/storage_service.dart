import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service for persistent local storage
class StorageService {
  static const String _matchesKey = 'matches';
  static const String _teamsKey = 'teams';
  static const String _playersKey = 'players';

  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== MATCHES ====================

  /// Save all matches
  Future<void> saveMatches(List<CricketMatch> matches) async {
    final jsonList = matches.map((m) => m.toJson()).toList();
    await _prefs?.setString(_matchesKey, jsonEncode(jsonList));
  }

  /// Load all matches
  Future<List<CricketMatch>> loadMatches() async {
    final jsonString = _prefs?.getString(_matchesKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((j) => CricketMatch.fromJson(j)).toList();
  }

  /// Save a single match (updates existing or adds new)
  Future<void> saveMatch(CricketMatch match) async {
    final matches = await loadMatches();
    final index = matches.indexWhere((m) => m.id == match.id);

    if (index >= 0) {
      matches[index] = match;
    } else {
      matches.add(match);
    }

    await saveMatches(matches);
  }

  /// Delete a match
  Future<void> deleteMatch(String matchId) async {
    final matches = await loadMatches();
    matches.removeWhere((m) => m.id == matchId);
    await saveMatches(matches);
  }

  // ==================== TEAMS ====================

  /// Save all teams
  Future<void> saveTeams(List<Team> teams) async {
    final jsonList = teams.map((t) => t.toJson()).toList();
    await _prefs?.setString(_teamsKey, jsonEncode(jsonList));
  }

  /// Load all teams
  Future<List<Team>> loadTeams() async {
    final jsonString = _prefs?.getString(_teamsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((j) => Team.fromJson(j)).toList();
  }

  /// Save a single team
  Future<void> saveTeam(Team team) async {
    final teams = await loadTeams();
    final index = teams.indexWhere((t) => t.id == team.id);

    if (index >= 0) {
      teams[index] = team;
    } else {
      teams.add(team);
    }

    await saveTeams(teams);
  }

  /// Delete a team
  Future<void> deleteTeam(String teamId) async {
    final teams = await loadTeams();
    teams.removeWhere((t) => t.id == teamId);
    await saveTeams(teams);
  }

  // ==================== PLAYERS ====================

  /// Save all players
  Future<void> savePlayers(List<Player> players) async {
    final jsonList = players.map((p) => p.toJson()).toList();
    await _prefs?.setString(_playersKey, jsonEncode(jsonList));
  }

  /// Load all players
  Future<List<Player>> loadPlayers() async {
    final jsonString = _prefs?.getString(_playersKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((j) => Player.fromJson(j)).toList();
  }

  /// Save a single player
  Future<void> savePlayer(Player player) async {
    final players = await loadPlayers();
    final index = players.indexWhere((p) => p.id == player.id);

    if (index >= 0) {
      players[index] = player;
    } else {
      players.add(player);
    }

    await savePlayers(players);
  }

  /// Delete a player
  Future<void> deletePlayer(String playerId) async {
    final players = await loadPlayers();
    players.removeWhere((p) => p.id == playerId);
    await savePlayers(players);
  }

  /// Get players by team
  Future<List<Player>> getPlayersByTeam(String teamId) async {
    final players = await loadPlayers();
    return players.where((p) => p.teamId == teamId).toList();
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
