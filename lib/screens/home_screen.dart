import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'live_scoring_screen.dart';
import 'schedule_match_screen.dart';
import 'player_stats_screen.dart';
import 'teams_screen.dart';

/// Main home screen with tabs for live, upcoming, and completed matches
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Cricket Scorer'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Live', icon: Icon(Icons.circle, size: 12, color: Colors.red)),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Teams & Players',
            onPressed: () => _navigateToTeams(context),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Player Stats',
            onPressed: () => _navigateToStats(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveMatches(context),
          _buildUpcomingMatches(context),
          _buildCompletedMatches(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scheduleMatch(context),
        icon: const Icon(Icons.add),
        label: const Text('New Match'),
      ),
    );
  }

  Widget _buildLiveMatches(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, provider, child) {
        final matches = provider.liveMatches;

        if (matches.isEmpty) {
          return _buildEmptyState(
            context,
            Icons.sports_cricket,
            'No Live Matches',
            'Live matches will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ScoreCard(
                match: match,
                showDetails: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUpcomingMatches(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, provider, child) {
        final matches = provider.scheduledMatches;

        if (matches.isEmpty) {
          return _buildEmptyState(
            context,
            Icons.calendar_today,
            'No Upcoming Matches',
            'Schedule a new match to get started',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MatchTile(
                match: match,
                onTap: () => _showMatchOptions(context, match),
                onLongPress: () => _confirmDeleteMatch(context, match),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedMatches(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, provider, child) {
        final matches = provider.completedMatches;

        if (matches.isEmpty) {
          return _buildEmptyState(
            context,
            Icons.history,
            'No Completed Matches',
            'Finished matches will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MatchTile(
                match: match,
                onTap: () => _viewMatchDetails(context, match),
                onLongPress: () => _confirmDeleteMatch(context, match),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleMatch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScheduleMatchScreen(),
      ),
    );
  }

  void _showMatchOptions(BuildContext context, CricketMatch match) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Start Match'),
              onTap: () {
                Navigator.pop(context);
                _startMatch(context, match);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Match'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Edit match
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Match', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteMatch(context, match);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startMatch(BuildContext context, CricketMatch match) {
    showDialog(
      context: context,
      builder: (context) => _TossDialog(match: match),
    );
  }

  void _viewMatchDetails(BuildContext context, CricketMatch match) {
    // Show detailed scorecard
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: ScoreCard(
            match: match,
            showDetails: true,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMatch(BuildContext context, CricketMatch match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match?'),
        content: Text('Are you sure you want to delete "${match.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MatchProvider>().deleteMatch(match.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToTeams(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TeamsScreen(),
      ),
    );
  }

  void _navigateToStats(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PlayerStatsScreen(),
      ),
    );
  }
}

/// Dialog for toss and match start
class _TossDialog extends StatefulWidget {
  final CricketMatch match;

  const _TossDialog({required this.match});

  @override
  State<_TossDialog> createState() => _TossDialogState();
}

class _TossDialogState extends State<_TossDialog> {
  String? _tossWinnerId;
  TossDecision? _decision;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Toss'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Who won the toss?'),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: Text(widget.match.team1.name),
            value: widget.match.team1.id,
            groupValue: _tossWinnerId,
            onChanged: (value) => setState(() => _tossWinnerId = value),
          ),
          RadioListTile<String>(
            title: Text(widget.match.team2.name),
            value: widget.match.team2.id,
            groupValue: _tossWinnerId,
            onChanged: (value) => setState(() => _tossWinnerId = value),
          ),
          const SizedBox(height: 16),
          if (_tossWinnerId != null) ...[
            const Text('Elected to:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Bat'),
                    selected: _decision == TossDecision.bat,
                    onSelected: (selected) {
                      setState(() => _decision = TossDecision.bat);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Bowl'),
                    selected: _decision == TossDecision.bowl,
                    onSelected: (selected) {
                      setState(() => _decision = TossDecision.bowl);
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _tossWinnerId != null && _decision != null
              ? () {
                  Navigator.pop(context);
                  context.read<MatchProvider>().startMatch(
                        widget.match.id,
                        _tossWinnerId!,
                        _decision!,
                      );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LiveScoringScreen(),
                    ),
                  );
                }
              : null,
          child: const Text('Start Match'),
        ),
      ],
    );
  }
}
