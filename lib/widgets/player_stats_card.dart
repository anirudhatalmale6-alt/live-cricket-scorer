import 'package:flutter/material.dart';
import '../models/models.dart';

/// Widget displaying detailed player statistics
class PlayerStatsCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;

  const PlayerStatsCard({
    super.key,
    required this.player,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player name and role
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getRoleText(player.role),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _getRoleIcon(player.role),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const Divider(height: 24),

              // Batting stats
              Text(
                'Batting',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildStatChip(context, 'Matches', player.matchesPlayed.toString()),
                  _buildStatChip(context, 'Innings', player.innings.toString()),
                  _buildStatChip(context, 'Runs', player.totalRuns.toString()),
                  _buildStatChip(context, 'HS', player.highestScore.toString()),
                  _buildStatChip(context, 'Avg', player.battingAverage.toStringAsFixed(2)),
                  _buildStatChip(context, 'SR', player.strikeRate.toStringAsFixed(2)),
                  _buildStatChip(context, '4s', player.fours.toString()),
                  _buildStatChip(context, '6s', player.sixes.toString()),
                ],
              ),

              if (player.wicketsTaken > 0 ||
                  player.role == PlayerRole.bowler ||
                  player.role == PlayerRole.allRounder) ...[
                const SizedBox(height: 16),
                Text(
                  'Bowling',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildStatChip(context, 'Wickets', player.wicketsTaken.toString()),
                    _buildStatChip(context, 'Overs', '${player.oversBowled}.${player.ballsBowled}'),
                    _buildStatChip(context, 'Runs', player.runsConceded.toString()),
                    _buildStatChip(context, 'Avg', player.bowlingAverage.toStringAsFixed(2)),
                    _buildStatChip(context, 'Eco', player.economyRate.toStringAsFixed(2)),
                    _buildStatChip(context, 'Best', '${player.bestBowlingWickets}/${player.bestBowlingRuns}'),
                  ],
                ),
              ],

              // Fielding stats
              if (player.catches > 0 || player.runOuts > 0 || player.stumpings > 0) ...[
                const SizedBox(height: 16),
                Text(
                  'Fielding',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildStatChip(context, 'Catches', player.catches.toString()),
                    _buildStatChip(context, 'Run Outs', player.runOuts.toString()),
                    if (player.role == PlayerRole.wicketKeeper)
                      _buildStatChip(context, 'Stumpings', player.stumpings.toString()),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
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

  IconData _getRoleIcon(PlayerRole role) {
    switch (role) {
      case PlayerRole.batsman:
        return Icons.sports_cricket;
      case PlayerRole.bowler:
        return Icons.sports_baseball;
      case PlayerRole.allRounder:
        return Icons.star;
      case PlayerRole.wicketKeeper:
        return Icons.sports_handball;
    }
  }
}
