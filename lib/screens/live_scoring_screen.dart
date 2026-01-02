import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

/// Screen for live match scoring
class LiveScoringScreen extends StatefulWidget {
  const LiveScoringScreen({super.key});

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends State<LiveScoringScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, provider, child) {
        final match = provider.activeMatch;

        if (match == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Live Scoring')),
            body: const Center(
              child: Text('No active match'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(match.title),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value, match),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'end_innings',
                    child: Text('End Innings'),
                  ),
                  const PopupMenuItem(
                    value: 'end_match',
                    child: Text('End Match'),
                  ),
                ],
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout
              if (constraints.maxWidth > 800) {
                return _buildWideLayout(context, match);
              } else {
                return _buildNarrowLayout(context, match);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context, CricketMatch match) {
    final innings = match.currentInnings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score card
          ScoreCard(match: match, showDetails: true),
          const SizedBox(height: 16),

          // Current players
          if (innings != null) ...[
            _buildBatsmenSection(context, match, innings),
            const SizedBox(height: 12),
            _buildBowlerSection(context, match, innings),
            const SizedBox(height: 16),
          ],

          // Scoring panel
          ScoringPanel(
            onDot: () => _recordBall(context, 0),
            onRuns: (runs) => _recordBall(context, runs),
            onFour: () => _recordBall(context, 4),
            onSix: () => _recordBall(context, 6),
            onWide: () => _recordExtra(context, ExtraType.wide),
            onNoBall: () => _recordExtra(context, ExtraType.noBall),
            onBye: () => _recordExtra(context, ExtraType.bye),
            onLegBye: () => _recordExtra(context, ExtraType.legBye),
            onWicket: () => _recordWicket(context),
            onUndo: () => _undoLastBall(context),
            onSwapBatsmen: () => _swapBatsmen(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, CricketMatch match) {
    final innings = match.currentInnings;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel - Match info
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ScoreCard(match: match, showDetails: true),
                const SizedBox(height: 16),
                if (innings != null) ...[
                  _buildBatsmenSection(context, match, innings),
                  const SizedBox(height: 12),
                  _buildBowlerSection(context, match, innings),
                ],
              ],
            ),
          ),
        ),

        // Right panel - Scoring
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ScoringPanel(
              onDot: () => _recordBall(context, 0),
              onRuns: (runs) => _recordBall(context, runs),
              onFour: () => _recordBall(context, 4),
              onSix: () => _recordBall(context, 6),
              onWide: () => _recordExtra(context, ExtraType.wide),
              onNoBall: () => _recordExtra(context, ExtraType.noBall),
              onBye: () => _recordExtra(context, ExtraType.bye),
              onLegBye: () => _recordExtra(context, ExtraType.legBye),
              onWicket: () => _recordWicket(context),
              onUndo: () => _undoLastBall(context),
              onSwapBatsmen: () => _swapBatsmen(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatsmenSection(
    BuildContext context,
    CricketMatch match,
    Innings innings,
  ) {
    final teamProvider = context.read<TeamProvider>();
    final strikerScore = innings.batsmanScores
        .where((s) => s.playerId == innings.currentBatsmanId)
        .firstOrNull;
    final nonStrikerScore = innings.batsmanScores
        .where((s) => s.playerId == innings.nonStrikerId)
        .firstOrNull;

    final strikerName = teamProvider.getPlayerById(innings.currentBatsmanId ?? '')?.name;
    final nonStrikerName = teamProvider.getPlayerById(innings.nonStrikerId ?? '')?.name;

    return Column(
      children: [
        BatsmanCard(
          striker: strikerScore,
          nonStriker: nonStrikerScore,
          strikerName: strikerName,
          nonStrikerName: nonStrikerName,
        ),
        if (innings.currentBatsmanId == null || innings.nonStrikerId == null)
          TextButton.icon(
            onPressed: () => _selectBatsmen(context, match, innings),
            icon: const Icon(Icons.person_add),
            label: const Text('Select Batsmen'),
          ),
      ],
    );
  }

  Widget _buildBowlerSection(
    BuildContext context,
    CricketMatch match,
    Innings innings,
  ) {
    final teamProvider = context.read<TeamProvider>();
    final bowlerStats = innings.bowlerStats
        .where((s) => s.playerId == innings.currentBowlerId)
        .firstOrNull;
    final bowlerName = teamProvider.getPlayerById(innings.currentBowlerId ?? '')?.name;

    return Column(
      children: [
        BowlerCard(
          bowler: bowlerStats,
          bowlerName: bowlerName,
        ),
        if (innings.currentBowlerId == null)
          TextButton.icon(
            onPressed: () => _selectBowler(context, match, innings),
            icon: const Icon(Icons.person_add),
            label: const Text('Select Bowler'),
          ),
      ],
    );
  }

  void _selectBatsmen(BuildContext context, CricketMatch match, Innings innings) {
    final battingTeam = match.battingTeam;
    if (battingTeam == null) return;

    showDialog(
      context: context,
      builder: (context) => _PlayerSelectionDialog(
        title: 'Select Batsmen',
        players: battingTeam.players,
        selectionCount: 2,
        onSelected: (players) {
          if (players.length >= 2) {
            context.read<MatchProvider>().setCurrentBatsmen(
                  players[0].id,
                  players[1].id,
                );
          }
        },
      ),
    );
  }

  void _selectBowler(BuildContext context, CricketMatch match, Innings innings) {
    final bowlingTeam = match.bowlingTeam;
    if (bowlingTeam == null) return;

    showDialog(
      context: context,
      builder: (context) => _PlayerSelectionDialog(
        title: 'Select Bowler',
        players: bowlingTeam.players,
        selectionCount: 1,
        onSelected: (players) {
          if (players.isNotEmpty) {
            context.read<MatchProvider>().setCurrentBowler(players[0].id);
          }
        },
      ),
    );
  }

  void _recordBall(BuildContext context, int runs) {
    context.read<MatchProvider>().recordBall(runs: runs);
  }

  void _recordExtra(BuildContext context, ExtraType type) {
    showDialog(
      context: context,
      builder: (context) => _ExtraRunsDialog(
        extraType: type,
        onConfirm: (runs, extraRuns) {
          context.read<MatchProvider>().recordBall(
                runs: runs,
                extraType: type,
                extraRuns: extraRuns,
              );
        },
      ),
    );
  }

  void _recordWicket(BuildContext context) {
    final match = context.read<MatchProvider>().activeMatch;
    if (match == null) return;

    showDialog(
      context: context,
      builder: (context) => _WicketDialog(
        match: match,
        onConfirm: (wicketType, dismissedId, fielderId, runs) {
          context.read<MatchProvider>().recordBall(
                runs: runs,
                isWicket: true,
                wicketType: wicketType,
                dismissedPlayerId: dismissedId,
                fielderId: fielderId,
              );
        },
      ),
    );
  }

  void _undoLastBall(BuildContext context) {
    context.read<MatchProvider>().undoLastBall();
  }

  void _swapBatsmen(BuildContext context) {
    context.read<MatchProvider>().swapBatsmen();
  }

  void _handleMenuAction(BuildContext context, String action, CricketMatch match) {
    switch (action) {
      case 'end_innings':
        _confirmEndInnings(context);
        break;
      case 'end_match':
        _confirmEndMatch(context);
        break;
    }
  }

  void _confirmEndInnings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Innings?'),
        content: const Text('Are you sure you want to end the current innings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MatchProvider>().startSecondInnings();
            },
            child: const Text('End Innings'),
          ),
        ],
      ),
    );
  }

  void _confirmEndMatch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Match?'),
        content: const Text('Are you sure you want to end the match?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MatchProvider>().endMatch(MatchStatus.completed);
              Navigator.pop(context); // Go back to home
            },
            child: const Text('End Match'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for selecting players
class _PlayerSelectionDialog extends StatefulWidget {
  final String title;
  final List<Player> players;
  final int selectionCount;
  final Function(List<Player>) onSelected;

  const _PlayerSelectionDialog({
    required this.title,
    required this.players,
    required this.selectionCount,
    required this.onSelected,
  });

  @override
  State<_PlayerSelectionDialog> createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<_PlayerSelectionDialog> {
  final List<Player> _selected = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.players.length,
          itemBuilder: (context, index) {
            final player = widget.players[index];
            final isSelected = _selected.contains(player);

            return CheckboxListTile(
              title: Text(player.name),
              subtitle: Text(_getRoleText(player.role)),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    if (_selected.length < widget.selectionCount) {
                      _selected.add(player);
                    }
                  } else {
                    _selected.remove(player);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selected.length == widget.selectionCount
              ? () {
                  widget.onSelected(_selected);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Confirm'),
        ),
      ],
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

/// Dialog for extra runs input
class _ExtraRunsDialog extends StatefulWidget {
  final ExtraType extraType;
  final Function(int runs, int extraRuns) onConfirm;

  const _ExtraRunsDialog({
    required this.extraType,
    required this.onConfirm,
  });

  @override
  State<_ExtraRunsDialog> createState() => _ExtraRunsDialogState();
}

class _ExtraRunsDialogState extends State<_ExtraRunsDialog> {
  int _runs = 0;
  int _extraRuns = 1;

  @override
  Widget build(BuildContext context) {
    final isWideOrNoBall =
        widget.extraType == ExtraType.wide || widget.extraType == ExtraType.noBall;

    return AlertDialog(
      title: Text(_getTitle()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWideOrNoBall) ...[
            const Text('Runs scored (off bat):'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [0, 1, 2, 3, 4, 6].map((r) {
                return ChoiceChip(
                  label: Text(r.toString()),
                  selected: _runs == r,
                  onSelected: (_) => setState(() => _runs = r),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Text('${_getExtraLabel()} runs:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [1, 2, 3, 4].map((r) {
              return ChoiceChip(
                label: Text(r.toString()),
                selected: _extraRuns == r,
                onSelected: (_) => setState(() => _extraRuns = r),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_runs, _extraRuns);
            Navigator.pop(context);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (widget.extraType) {
      case ExtraType.wide:
        return 'Wide';
      case ExtraType.noBall:
        return 'No Ball';
      case ExtraType.bye:
        return 'Bye';
      case ExtraType.legBye:
        return 'Leg Bye';
    }
  }

  String _getExtraLabel() {
    switch (widget.extraType) {
      case ExtraType.wide:
        return 'Wide';
      case ExtraType.noBall:
        return 'No ball';
      case ExtraType.bye:
        return 'Bye';
      case ExtraType.legBye:
        return 'Leg bye';
    }
  }
}

/// Dialog for wicket recording
class _WicketDialog extends StatefulWidget {
  final CricketMatch match;
  final Function(WicketType, String, String?, int) onConfirm;

  const _WicketDialog({
    required this.match,
    required this.onConfirm,
  });

  @override
  State<_WicketDialog> createState() => _WicketDialogState();
}

class _WicketDialogState extends State<_WicketDialog> {
  WicketType? _wicketType;
  String? _dismissedPlayerId;
  String? _fielderId;
  int _runs = 0;

  @override
  Widget build(BuildContext context) {
    final innings = widget.match.currentInnings;
    final battingTeam = widget.match.battingTeam;
    final bowlingTeam = widget.match.bowlingTeam;

    return AlertDialog(
      title: const Text('Wicket'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type of dismissal:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WicketType.values.map((type) {
                return ChoiceChip(
                  label: Text(_getWicketLabel(type)),
                  selected: _wicketType == type,
                  onSelected: (_) => setState(() => _wicketType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Text('Dismissed player:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _dismissedPlayerId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                if (innings?.currentBatsmanId != null)
                  DropdownMenuItem(
                    value: innings!.currentBatsmanId,
                    child: Text(_getPlayerName(battingTeam, innings.currentBatsmanId!)),
                  ),
                if (innings?.nonStrikerId != null)
                  DropdownMenuItem(
                    value: innings!.nonStrikerId,
                    child: Text(_getPlayerName(battingTeam, innings.nonStrikerId!)),
                  ),
              ],
              onChanged: (value) => setState(() => _dismissedPlayerId = value),
            ),

            if (_needsFielder()) ...[
              const SizedBox(height: 16),
              const Text('Fielder:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _fielderId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: bowlingTeam?.players.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name),
                  );
                }).toList() ?? [],
                onChanged: (value) => setState(() => _fielderId = value),
              ),
            ],

            if (_wicketType == WicketType.runOut) ...[
              const SizedBox(height: 16),
              const Text('Runs completed:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [0, 1, 2].map((r) {
                  return ChoiceChip(
                    label: Text(r.toString()),
                    selected: _runs == r,
                    onSelected: (_) => setState(() => _runs = r),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _wicketType != null && _dismissedPlayerId != null
              ? () {
                  widget.onConfirm(
                    _wicketType!,
                    _dismissedPlayerId!,
                    _fielderId,
                    _runs,
                  );
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  bool _needsFielder() {
    return _wicketType == WicketType.caught ||
        _wicketType == WicketType.runOut ||
        _wicketType == WicketType.stumped;
  }

  String _getPlayerName(Team? team, String playerId) {
    return team?.players.firstWhere((p) => p.id == playerId).name ?? 'Unknown';
  }

  String _getWicketLabel(WicketType type) {
    switch (type) {
      case WicketType.bowled:
        return 'Bowled';
      case WicketType.caught:
        return 'Caught';
      case WicketType.lbw:
        return 'LBW';
      case WicketType.runOut:
        return 'Run Out';
      case WicketType.stumped:
        return 'Stumped';
      case WicketType.hitWicket:
        return 'Hit Wicket';
      case WicketType.handledBall:
        return 'Handled Ball';
      case WicketType.obstructingField:
        return 'Obstructing';
      case WicketType.timedOut:
        return 'Timed Out';
      case WicketType.retired:
        return 'Retired';
    }
  }
}
