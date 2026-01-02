import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../models/models.dart';

/// Screen for managing teams and players
class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams & Players'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Sample Teams',
            onPressed: () => _addSampleTeams(context),
          ),
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, child) {
          final teams = provider.teams;

          if (teams.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return _buildTeamCard(context, team);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTeamDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Team'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Teams Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create teams to get started with matches',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _addSampleTeams(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Add Sample Teams'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, Team team) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            team.displayShortName,
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          team.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${team.players.length} players'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showAddPlayerDialog(context, team),
              tooltip: 'Add Player',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDeleteTeam(context, team),
              tooltip: 'Delete Team',
            ),
          ],
        ),
        children: [
          if (team.players.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No players added yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...team.players.map((player) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Text(
                      player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  title: Text(player.name),
                  subtitle: Text(_getRoleText(player.role)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _confirmDeletePlayer(context, player),
                  ),
                )),
        ],
      ),
    );
  }

  void _showAddTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    final shortNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                hintText: 'e.g., Mumbai Indians',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: shortNameController,
              decoration: const InputDecoration(
                labelText: 'Short Name (optional)',
                hintText: 'e.g., MI',
                border: OutlineInputBorder(),
              ),
              maxLength: 5,
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
              if (nameController.text.isNotEmpty) {
                context.read<TeamProvider>().createTeam(
                      name: nameController.text,
                      shortName: shortNameController.text.isNotEmpty
                          ? shortNameController.text.toUpperCase()
                          : null,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context, Team team) {
    final nameController = TextEditingController();
    PlayerRole selectedRole = PlayerRole.allRounder;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Player to ${team.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Player Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Role:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PlayerRole.values.map((role) {
                  return ChoiceChip(
                    label: Text(_getRoleText(role)),
                    selected: selectedRole == role,
                    onSelected: (_) => setState(() => selectedRole = role),
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
                if (nameController.text.isNotEmpty) {
                  context.read<TeamProvider>().addPlayer(
                        name: nameController.text,
                        teamId: team.id,
                        role: selectedRole,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTeam(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team?'),
        content: Text(
          'Are you sure you want to delete "${team.name}" and all its players?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TeamProvider>().deleteTeam(team.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlayer(BuildContext context, Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player?'),
        content: Text('Are you sure you want to delete "${player.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TeamProvider>().deletePlayer(player.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addSampleTeams(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sample Teams?'),
        content: const Text(
          'This will add sample IPL teams (Mumbai Indians and Chennai Super Kings) with players. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TeamProvider>().createSampleData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sample teams added!')),
              );
            },
            child: const Text('Add'),
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
}
