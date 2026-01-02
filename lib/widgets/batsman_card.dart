import 'package:flutter/material.dart';
import '../models/models.dart';

/// Widget displaying current batsmen info
class BatsmanCard extends StatelessWidget {
  final BatsmanScore? striker;
  final BatsmanScore? nonStriker;
  final String? strikerName;
  final String? nonStrikerName;

  const BatsmanCard({
    super.key,
    this.striker,
    this.nonStriker,
    this.strikerName,
    this.nonStrikerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batting',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // Header row
            Row(
              children: [
                const SizedBox(width: 24), // Space for strike indicator
                Expanded(
                  flex: 3,
                  child: Text(
                    'Batsman',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _headerText(context, 'R'),
                _headerText(context, 'B'),
                _headerText(context, '4s'),
                _headerText(context, '6s'),
                _headerText(context, 'SR'),
              ],
            ),
            const Divider(height: 16),

            // Striker
            if (striker != null)
              _buildBatsmanRow(
                context,
                strikerName ?? 'Batsman 1',
                striker!,
                isStriker: true,
              )
            else
              _buildEmptyRow(context, 'Select striker'),

            const SizedBox(height: 8),

            // Non-striker
            if (nonStriker != null)
              _buildBatsmanRow(
                context,
                nonStrikerName ?? 'Batsman 2',
                nonStriker!,
                isStriker: false,
              )
            else
              _buildEmptyRow(context, 'Select non-striker'),
          ],
        ),
      ),
    );
  }

  Widget _headerText(BuildContext context, String text) {
    return SizedBox(
      width: 36,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBatsmanRow(
    BuildContext context,
    String name,
    BatsmanScore score, {
    required bool isStriker,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Strike indicator
        SizedBox(
          width: 24,
          child: isStriker
              ? Icon(
                  Icons.sports_cricket,
                  size: 16,
                  color: theme.colorScheme.primary,
                )
              : null,
        ),

        // Name
        Expanded(
          flex: 3,
          child: Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isStriker ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Runs
        _statText(context, score.runs.toString(), isStriker),

        // Balls
        _statText(context, score.ballsFaced.toString(), isStriker),

        // 4s
        _statText(context, score.fours.toString(), isStriker),

        // 6s
        _statText(context, score.sixes.toString(), isStriker),

        // SR
        _statText(context, score.strikeRate.toStringAsFixed(1), isStriker),
      ],
    );
  }

  Widget _statText(BuildContext context, String text, bool highlight) {
    return SizedBox(
      width: 36,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyRow(BuildContext context, String text) {
    return Row(
      children: [
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget displaying current bowler info
class BowlerCard extends StatelessWidget {
  final BowlerStats? bowler;
  final String? bowlerName;

  const BowlerCard({
    super.key,
    this.bowler,
    this.bowlerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bowling',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // Header row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Bowler',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _headerText(context, 'O'),
                _headerText(context, 'M'),
                _headerText(context, 'R'),
                _headerText(context, 'W'),
                _headerText(context, 'Eco'),
              ],
            ),
            const Divider(height: 16),

            // Bowler
            if (bowler != null)
              _buildBowlerRow(context, bowlerName ?? 'Bowler', bowler!)
            else
              Text(
                'Select bowler',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerText(BuildContext context, String text) {
    return SizedBox(
      width: 40,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBowlerRow(
    BuildContext context,
    String name,
    BowlerStats stats,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Overs
        SizedBox(
          width: 40,
          child: Text(
            stats.oversDisplay,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),

        // Maidens
        SizedBox(
          width: 40,
          child: Text(
            stats.maidens.toString(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),

        // Runs
        SizedBox(
          width: 40,
          child: Text(
            stats.runsConceded.toString(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),

        // Wickets
        SizedBox(
          width: 40,
          child: Text(
            stats.wickets.toString(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: stats.wickets > 0 ? Colors.green : null,
            ),
          ),
        ),

        // Economy
        SizedBox(
          width: 40,
          child: Text(
            stats.economy.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
