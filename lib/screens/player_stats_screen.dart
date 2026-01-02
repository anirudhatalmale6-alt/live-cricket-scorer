import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

/// Screen displaying player statistics
class PlayerStatsScreen extends StatefulWidget {
  const PlayerStatsScreen({super.key});

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  PlayerRole? _filterRole;
  String? _filterTeamId;
  String _sortBy = 'runs';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Statistics'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Batting'),
            Tab(text: 'Bowling'),
            Tab(text: 'All Players'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search players...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter',
                  onSelected: (value) {
                    if (value.startsWith('team_')) {
                      setState(() {
                        _filterTeamId = value.substring(5);
                        if (_filterTeamId == 'all') _filterTeamId = null;
                      });
                    } else if (value.startsWith('role_')) {
                      setState(() {
                        final roleStr = value.substring(5);
                        if (roleStr == 'all') {
                          _filterRole = null;
                        } else {
                          _filterRole = PlayerRole.values.firstWhere(
                            (r) => r.name == roleStr,
                          );
                        }
                      });
                    }
                  },
                  itemBuilder: (context) {
                    final teams = context.read<TeamProvider>().teams;
                    return [
                      const PopupMenuItem(
                        enabled: false,
                        child: Text('Filter by Team'),
                      ),
                      const PopupMenuItem(
                        value: 'team_all',
                        child: Text('All Teams'),
                      ),
                      ...teams.map((t) => PopupMenuItem(
                            value: 'team_${t.id}',
                            child: Text(t.name),
                          )),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        enabled: false,
                        child: Text('Filter by Role'),
                      ),
                      const PopupMenuItem(
                        value: 'role_all',
                        child: Text('All Roles'),
                      ),
                      ...PlayerRole.values.map((r) => PopupMenuItem(
                            value: 'role_${r.name}',
                            child: Text(_getRoleText(r)),
                          )),
                    ];
                  },
                ),
              ],
            ),
          ),

          // Stats content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBattingStats(context),
                _buildBowlingStats(context),
                _buildAllPlayers(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattingStats(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, provider, child) {
        var players = _getFilteredPlayers(provider.players);

        // Sort by runs
        players.sort((a, b) => b.totalRuns.compareTo(a.totalRuns));

        if (players.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return _buildBattingStatTile(context, player, index + 1);
          },
        );
      },
    );
  }

  Widget _buildBowlingStats(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, provider, child) {
        var players = _getFilteredPlayers(provider.players)
            .where((p) => p.wicketsTaken > 0 ||
                p.role == PlayerRole.bowler ||
                p.role == PlayerRole.allRounder)
            .toList();

        // Sort by wickets
        players.sort((a, b) => b.wicketsTaken.compareTo(a.wicketsTaken));

        if (players.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return _buildBowlingStatTile(context, player, index + 1);
          },
        );
      },
    );
  }

  Widget _buildAllPlayers(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, provider, child) {
        final players = _getFilteredPlayers(provider.players);

        if (players.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PlayerStatsCard(
                player: player,
                onTap: () => _showPlayerDetails(context, player),
              ),
            );
          },
        );
      },
    );
  }

  List<Player> _getFilteredPlayers(List<Player> players) {
    return players.where((p) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!p.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Team filter
      if (_filterTeamId != null && p.teamId != _filterTeamId) {
        return false;
      }

      // Role filter
      if (_filterRole != null && p.role != _filterRole) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildBattingStatTile(BuildContext context, Player player, int rank) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3
              ? (rank == 1
                  ? Colors.amber
                  : rank == 2
                      ? Colors.grey.shade400
                      : Colors.brown.shade300)
              : theme.colorScheme.primaryContainer,
          child: Text(
            rank.toString(),
            style: TextStyle(
              color: rank <= 3 ? Colors.white : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Avg: ${player.battingAverage.toStringAsFixed(2)} | SR: ${player.strikeRate.toStringAsFixed(2)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${player.totalRuns}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'runs',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: () => _showPlayerDetails(context, player),
      ),
    );
  }

  Widget _buildBowlingStatTile(BuildContext context, Player player, int rank) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3
              ? (rank == 1
                  ? Colors.amber
                  : rank == 2
                      ? Colors.grey.shade400
                      : Colors.brown.shade300)
              : theme.colorScheme.primaryContainer,
          child: Text(
            rank.toString(),
            style: TextStyle(
              color: rank <= 3 ? Colors.white : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Avg: ${player.bowlingAverage.toStringAsFixed(2)} | Eco: ${player.economyRate.toStringAsFixed(2)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${player.wicketsTaken}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'wickets',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: () => _showPlayerDetails(context, player),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No players found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Add players to teams to see stats',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlayerDetails(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: PlayerStatsCard(player: player),
        ),
      ),
    );
  }

  String _getRoleText(PlayerRole role) {
    switch (role) {
      case PlayerRole.batsman:
        return 'Batsman';
      case PlayerRole.bowler:
        return 'Bowler';
      case PlayerRole.allRounder:
        return 'All-Rounder';
      case PlayerRole.wicketKeeper:
        return 'Wicket Keeper';
    }
  }
}
