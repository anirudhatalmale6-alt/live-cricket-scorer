import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// Provider for team and player management
class TeamProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<Team> _teams = [];
  List<Player> _players = [];
  bool _isLoading = false;
  String? _error;

  TeamProvider({required StorageService storageService})
      : _storageService = storageService;

  // Getters
  List<Team> get teams => _teams;
  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all teams and players
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teams = await _storageService.loadTeams();
      _players = await _storageService.loadPlayers();

      // Associate players with teams
      for (final team in _teams) {
        team.players = _players.where((p) => p.teamId == team.id).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new team
  Future<Team> createTeam({
    required String name,
    String? shortName,
    String? logoUrl,
  }) async {
    final team = Team(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      shortName: shortName,
      logoUrl: logoUrl,
    );

    _teams.add(team);
    await _storageService.saveTeam(team);
    notifyListeners();

    return team;
  }

  /// Update a team
  Future<void> updateTeam(Team team) async {
    final index = _teams.indexWhere((t) => t.id == team.id);
    if (index >= 0) {
      _teams[index] = team;
      await _storageService.saveTeam(team);
      notifyListeners();
    }
  }

  /// Delete a team
  Future<void> deleteTeam(String teamId) async {
    _teams.removeWhere((t) => t.id == teamId);
    // Also remove team's players
    _players.removeWhere((p) => p.teamId == teamId);
    await _storageService.deleteTeam(teamId);
    await _storageService.savePlayers(_players);
    notifyListeners();
  }

  /// Add a player to a team
  Future<Player> addPlayer({
    required String name,
    required String teamId,
    PlayerRole role = PlayerRole.allRounder,
  }) async {
    final player = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      teamId: teamId,
      role: role,
    );

    _players.add(player);

    // Also add to team's player list
    final team = _teams.firstWhere((t) => t.id == teamId);
    team.players.add(player);

    await _storageService.savePlayer(player);
    notifyListeners();

    return player;
  }

  /// Update a player
  Future<void> updatePlayer(Player player) async {
    final index = _players.indexWhere((p) => p.id == player.id);
    if (index >= 0) {
      _players[index] = player;

      // Update in team's list too
      final team = _teams.firstWhere((t) => t.id == player.teamId);
      final teamPlayerIndex = team.players.indexWhere((p) => p.id == player.id);
      if (teamPlayerIndex >= 0) {
        team.players[teamPlayerIndex] = player;
      }

      await _storageService.savePlayer(player);
      notifyListeners();
    }
  }

  /// Update player statistics after a match
  Future<void> updatePlayerStats(
    String playerId, {
    int? runsScored,
    int? ballsFaced,
    int? fours,
    int? sixes,
    bool? isNotOut,
    int? wicketsTaken,
    int? oversBowled,
    int? ballsBowled,
    int? runsConceded,
    int? maidens,
    int? catches,
    int? runOuts,
    int? stumpings,
  }) async {
    final player = _players.firstWhere((p) => p.id == playerId);

    // Update career stats
    if (runsScored != null) player.totalRuns += runsScored;
    if (ballsFaced != null) player.ballsFaced += ballsFaced;
    if (fours != null) player.fours += fours;
    if (sixes != null) player.sixes += sixes;
    if (isNotOut == true) player.notOuts++;
    if (wicketsTaken != null) player.wicketsTaken += wicketsTaken;
    if (oversBowled != null) player.oversBowled += oversBowled;
    if (ballsBowled != null) player.ballsBowled += ballsBowled;
    if (runsConceded != null) player.runsConceded += runsConceded;
    if (maidens != null) player.maidens += maidens;
    if (catches != null) player.catches += catches;
    if (runOuts != null) player.runOuts += runOuts;
    if (stumpings != null) player.stumpings += stumpings;

    await _storageService.savePlayer(player);
    notifyListeners();
  }

  /// Delete a player
  Future<void> deletePlayer(String playerId) async {
    final player = _players.firstWhere((p) => p.id == playerId);
    _players.removeWhere((p) => p.id == playerId);

    // Remove from team's list too
    final team = _teams.firstWhere((t) => t.id == player.teamId);
    team.players.removeWhere((p) => p.id == playerId);

    await _storageService.deletePlayer(playerId);
    notifyListeners();
  }

  /// Get players for a specific team
  List<Player> getPlayersForTeam(String teamId) {
    return _players.where((p) => p.teamId == teamId).toList();
  }

  /// Get a team by ID
  Team? getTeamById(String teamId) {
    try {
      return _teams.firstWhere((t) => t.id == teamId);
    } catch (e) {
      return null;
    }
  }

  /// Get a player by ID
  Player? getPlayerById(String playerId) {
    try {
      return _players.firstWhere((p) => p.id == playerId);
    } catch (e) {
      return null;
    }
  }

  /// Create sample teams and players for demo
  Future<void> createSampleData() async {
    // Create sample teams
    final team1 = await createTeam(
      name: 'Mumbai Indians',
      shortName: 'MI',
    );

    final team2 = await createTeam(
      name: 'Chennai Super Kings',
      shortName: 'CSK',
    );

    // Add players to team 1
    final miPlayers = [
      ('Rohit Sharma', PlayerRole.batsman),
      ('Ishan Kishan', PlayerRole.wicketKeeper),
      ('Suryakumar Yadav', PlayerRole.batsman),
      ('Tilak Varma', PlayerRole.allRounder),
      ('Hardik Pandya', PlayerRole.allRounder),
      ('Tim David', PlayerRole.batsman),
      ('Nehal Wadhera', PlayerRole.allRounder),
      ('Piyush Chawla', PlayerRole.bowler),
      ('Jasprit Bumrah', PlayerRole.bowler),
      ('Akash Madhwal', PlayerRole.bowler),
      ('Arjun Tendulkar', PlayerRole.bowler),
    ];

    for (final (name, role) in miPlayers) {
      await addPlayer(name: name, teamId: team1.id, role: role);
    }

    // Add players to team 2
    final cskPlayers = [
      ('Ruturaj Gaikwad', PlayerRole.batsman),
      ('Devon Conway', PlayerRole.batsman),
      ('Ajinkya Rahane', PlayerRole.batsman),
      ('Shivam Dube', PlayerRole.allRounder),
      ('Ravindra Jadeja', PlayerRole.allRounder),
      ('MS Dhoni', PlayerRole.wicketKeeper),
      ('Moeen Ali', PlayerRole.allRounder),
      ('Deepak Chahar', PlayerRole.bowler),
      ('Tushar Deshpande', PlayerRole.bowler),
      ('Matheesha Pathirana', PlayerRole.bowler),
      ('Maheesh Theekshana', PlayerRole.bowler),
    ];

    for (final (name, role) in cskPlayers) {
      await addPlayer(name: name, teamId: team2.id, role: role);
    }
  }
}
