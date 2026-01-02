import 'package:flutter/material.dart';
import '../models/models.dart';

/// Widget displaying live match score card
class ScoreCard extends StatelessWidget {
  final CricketMatch match;
  final bool showDetails;

  const ScoreCard({
    super.key,
    required this.match,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final innings = match.currentInnings;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match title and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(theme),
              ],
            ),
            const SizedBox(height: 8),

            // Format and venue
            Text(
              '${match.format.displayName} • ${match.venue}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Teams and scores
            _buildTeamScore(context, match.team1, match.innings),
            const SizedBox(height: 8),
            _buildTeamScore(context, match.team2, match.innings),

            // Extra info for live matches
            if (match.isLive && innings != null) ...[
              const Divider(height: 24),
              _buildLiveInfo(context, innings),
            ],

            // Result for completed matches
            if (match.isCompleted && match.result != null) ...[
              const SizedBox(height: 12),
              Text(
                match.result!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],

            // Details section
            if (showDetails && innings != null) ...[
              const Divider(height: 24),
              _buildCurrentOver(context, innings),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    Color backgroundColor;
    String label;

    switch (match.status) {
      case MatchStatus.scheduled:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        label = 'Scheduled';
        break;
      case MatchStatus.inProgress:
        backgroundColor = Colors.red;
        label = 'LIVE';
        break;
      case MatchStatus.completed:
        backgroundColor = Colors.green;
        label = 'Completed';
        break;
      case MatchStatus.abandoned:
        backgroundColor = Colors.grey;
        label = 'Abandoned';
        break;
      case MatchStatus.postponed:
        backgroundColor = Colors.orange;
        label = 'Postponed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: match.status == MatchStatus.scheduled
              ? theme.colorScheme.onSurfaceVariant
              : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTeamScore(
    BuildContext context,
    Team team,
    List<Innings> innings,
  ) {
    final theme = Theme.of(context);

    // Find innings for this team
    final teamInnings = innings.where((i) => i.battingTeamId == team.id).toList();

    return Row(
      children: [
        // Team name/logo
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              team.displayShortName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Team name
        Expanded(
          child: Text(
            team.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Score
        if (teamInnings.isNotEmpty)
          Text(
            '${teamInnings.first.totalRuns}/${teamInnings.first.wickets} (${teamInnings.first.oversDisplay})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            'Yet to bat',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildLiveInfo(BuildContext context, Innings innings) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(context, 'CRR', innings.runRate.toStringAsFixed(2)),
        if (match.target != null)
          _buildStatItem(context, 'Target', match.target.toString()),
        if (match.runsNeeded != null && match.runsNeeded! > 0)
          _buildStatItem(context, 'Need', match.runsNeeded.toString()),
        if (match.requiredRunRate != null)
          _buildStatItem(context, 'RRR', match.requiredRunRate!.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentOver(BuildContext context, Innings innings) {
    final theme = Theme.of(context);
    final overBalls = innings.currentOverBalls;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Over',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: overBalls.map((ball) => _buildBallChip(context, ball)).toList(),
        ),
      ],
    );
  }

  Widget _buildBallChip(BuildContext context, String text) {
    Color backgroundColor;
    Color textColor = Colors.white;

    if (text == 'W') {
      backgroundColor = Colors.red;
    } else if (text == '4') {
      backgroundColor = Colors.blue;
    } else if (text == '6') {
      backgroundColor = Colors.purple;
    } else if (text.contains('Wd') || text.contains('Nb')) {
      backgroundColor = Colors.orange;
    } else if (text == '•') {
      backgroundColor = Colors.grey;
    } else {
      backgroundColor = Colors.green;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
