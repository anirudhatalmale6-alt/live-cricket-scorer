import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../models/models.dart';

/// Screen for scheduling a new match
class ScheduleMatchScreen extends StatefulWidget {
  const ScheduleMatchScreen({super.key});

  @override
  State<ScheduleMatchScreen> createState() => _ScheduleMatchScreenState();
}

class _ScheduleMatchScreenState extends State<ScheduleMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _oversController = TextEditingController();

  Team? _team1;
  Team? _team2;
  MatchFormat _format = MatchFormat.t20;
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _oversController.text = _format.defaultOvers.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _oversController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Match'),
        centerTitle: true,
      ),
      body: Consumer<TeamProvider>(
        builder: (context, teamProvider, child) {
          final teams = teamProvider.teams;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Match title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Match Title',
                    hintText: 'e.g., IPL 2024 - Match 1',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter match title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Team 1 selection
                DropdownButtonFormField<Team>(
                  value: _team1,
                  decoration: const InputDecoration(
                    labelText: 'Team 1',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  items: teams
                      .where((t) => t != _team2)
                      .map((team) => DropdownMenuItem(
                            value: team,
                            child: Text(team.name),
                          ))
                      .toList(),
                  onChanged: (team) => setState(() => _team1 = team),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select team 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Team 2 selection
                DropdownButtonFormField<Team>(
                  value: _team2,
                  decoration: const InputDecoration(
                    labelText: 'Team 2',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  items: teams
                      .where((t) => t != _team1)
                      .map((team) => DropdownMenuItem(
                            value: team,
                            child: Text(team.name),
                          ))
                      .toList(),
                  onChanged: (team) => setState(() => _team2 = team),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select team 2';
                    }
                    return null;
                  },
                ),

                if (teams.length < 2) ...[
                  const SizedBox(height: 8),
                  Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You need at least 2 teams to schedule a match. Create teams first.',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Match format
                const Text('Match Format'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MatchFormat.values.map((format) {
                    return ChoiceChip(
                      label: Text(format.displayName),
                      selected: _format == format,
                      onSelected: (selected) {
                        setState(() {
                          _format = format;
                          _oversController.text = format.defaultOvers.toString();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Overs
                TextFormField(
                  controller: _oversController,
                  decoration: const InputDecoration(
                    labelText: 'Overs per innings',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sports_cricket),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of overs';
                    }
                    final overs = int.tryParse(value);
                    if (overs == null || overs <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Venue
                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(
                    labelText: 'Venue',
                    hintText: 'e.g., Wankhede Stadium, Mumbai',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.stadium),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter venue';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date and time
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_scheduledDate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _selectTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(
                            _scheduledTime.format(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: teams.length >= 2 ? _scheduleMatch : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Schedule Match',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _scheduledDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );

    if (time != null) {
      setState(() => _scheduledTime = time);
    }
  }

  void _scheduleMatch() {
    if (!_formKey.currentState!.validate()) return;
    if (_team1 == null || _team2 == null) return;

    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    context.read<MatchProvider>().createMatch(
          title: _titleController.text,
          team1: _team1!,
          team2: _team2!,
          format: _format,
          totalOvers: int.parse(_oversController.text),
          venue: _venueController.text,
          scheduledTime: scheduledDateTime,
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match scheduled successfully!')),
    );
  }
}
