import 'package:flutter/material.dart';

/// Widget for scoring input during a live match
class ScoringPanel extends StatelessWidget {
  final VoidCallback onDot;
  final ValueChanged<int> onRuns;
  final VoidCallback onFour;
  final VoidCallback onSix;
  final VoidCallback onWide;
  final VoidCallback onNoBall;
  final VoidCallback onBye;
  final VoidCallback onLegBye;
  final VoidCallback onWicket;
  final VoidCallback onUndo;
  final VoidCallback onSwapBatsmen;

  const ScoringPanel({
    super.key,
    required this.onDot,
    required this.onRuns,
    required this.onFour,
    required this.onSix,
    required this.onWide,
    required this.onNoBall,
    required this.onBye,
    required this.onLegBye,
    required this.onWicket,
    required this.onUndo,
    required this.onSwapBatsmen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Runs row
            Row(
              children: [
                _buildRunButton(context, 0, 'Dot', Colors.grey, onDot),
                const SizedBox(width: 8),
                _buildRunButton(context, 1, '1', Colors.green, () => onRuns(1)),
                const SizedBox(width: 8),
                _buildRunButton(context, 2, '2', Colors.green, () => onRuns(2)),
                const SizedBox(width: 8),
                _buildRunButton(context, 3, '3', Colors.green, () => onRuns(3)),
              ],
            ),
            const SizedBox(height: 8),

            // Boundaries row
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    '4',
                    Colors.blue,
                    onFour,
                    icon: Icons.sports_cricket,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context,
                    '6',
                    Colors.purple,
                    onSix,
                    icon: Icons.sports_cricket,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Extras row
            Text(
              'Extras',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildExtraButton(context, 'Wide', Colors.orange, onWide),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildExtraButton(context, 'No Ball', Colors.orange, onNoBall),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildExtraButton(context, 'Bye', Colors.amber, onBye),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildExtraButton(context, 'Leg Bye', Colors.amber, onLegBye),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Wicket row
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onWicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.sports_cricket),
                label: const Text(
                  'WICKET',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onUndo,
                    icon: const Icon(Icons.undo),
                    label: const Text('Undo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSwapBatsmen,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Swap'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunButton(
    BuildContext context,
    int runs,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed, {
    IconData? icon,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
