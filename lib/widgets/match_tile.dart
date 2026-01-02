import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

/// Compact match tile for lists
class MatchTile extends StatelessWidget {
  final CricketMatch match;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MatchTile({
    super.key,
    required this.match,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and status row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      match.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(theme),
                ],
              ),
              const SizedBox(height: 4),

              // Date and venue
              Text(
                '${dateFormat.format(match.scheduledTime)} • ${match.venue}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Teams
              Row(
                children: [
                  Expanded(
                    child: _buildTeamRow(context, match.team1, true),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'vs',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildTeamRow(context, match.team2, false),
                  ),
                ],
              ),

              // Show scores if available
              if (match.innings.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildScoreRow(context),
              ],

              // Result for completed matches
              if (match.isCompleted && match.result != null) ...[
                const SizedBox(height: 8),
                Text(
                  match.result!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    Color color;
    String text;

    switch (match.status) {
      case MatchStatus.scheduled:
        color = Colors.blue;
        text = match.format.displayName;
        break;
      case MatchStatus.inProgress:
        color = Colors.red;
        text = 'LIVE';
        break;
      case MatchStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case MatchStatus.abandoned:
        color = Colors.grey;
        text = 'Abandoned';
        break;
      case MatchStatus.postponed:
        color = Colors.orange;
        text = 'Postponed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, Team team, bool alignStart) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment:
          alignStart ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!alignStart) ...[
          Text(
            team.name,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 8),
        ],
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              team.displayShortName,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ),
        if (alignStart) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              team.name,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScoreRow(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Team 1 score
        _buildTeamScore(context, match.team1.id),
        // Team 2 score
        _buildTeamScore(context, match.team2.id),
      ],
    );
  }

  Widget _buildTeamScore(BuildContext context, String teamId) {
    final theme = Theme.of(context);
    final teamInnings = match.innings.where((i) => i.battingTeamId == teamId).toList();

    if (teamInnings.isEmpty) {
      return Text(
        'Yet to bat',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final innings = teamInnings.first;
    return Text(
      '${innings.totalRuns}/${innings.wickets} (${innings.oversDisplay})',
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
