// Basic Flutter widget test for Live Cricket Scorer

import 'package:flutter_test/flutter_test.dart';
import 'package:live_cricket_scorer/models/models.dart';

void main() {
  group('Player Model Tests', () {
    test('Player batting average calculation', () {
      final player = Player(
        id: '1',
        name: 'Test Player',
        teamId: 'team1',
        totalRuns: 100,
        innings: 5,
        notOuts: 1,
      );

      // Average = runs / (innings - not outs) = 100 / 4 = 25
      expect(player.battingAverage, 25.0);
    });

    test('Player strike rate calculation', () {
      final player = Player(
        id: '1',
        name: 'Test Player',
        teamId: 'team1',
        totalRuns: 50,
        ballsFaced: 40,
      );

      // Strike rate = (runs / balls) * 100 = 125
      expect(player.strikeRate, 125.0);
    });

    test('Player bowling economy calculation', () {
      final player = Player(
        id: '1',
        name: 'Test Bowler',
        teamId: 'team1',
        runsConceded: 30,
        oversBowled: 5,
        ballsBowled: 0,
      );

      // Economy = runs / overs = 6.0
      expect(player.economyRate, 6.0);
    });
  });

  group('Team Model Tests', () {
    test('Team short name generation', () {
      final team = Team(id: '1', name: 'Mumbai Indians');
      expect(team.displayShortName, 'MUM');

      final teamWithShort = Team(id: '2', name: 'Chennai Super Kings', shortName: 'CSK');
      expect(teamWithShort.displayShortName, 'CSK');
    });
  });

  group('Match Model Tests', () {
    test('Match format default overs', () {
      expect(MatchFormat.t20.defaultOvers, 20);
      expect(MatchFormat.odi.defaultOvers, 50);
      expect(MatchFormat.t10.defaultOvers, 10);
    });
  });

  group('Ball Event Tests', () {
    test('Ball display text for different outcomes', () {
      final dotBall = BallEvent(
        id: '1',
        matchId: 'm1',
        inningsNumber: 1,
        overNumber: 0,
        ballNumber: 0,
        batsmanId: 'b1',
        bowlerId: 'bowl1',
        runs: 0,
      );
      expect(dotBall.displayText, '•');

      final four = BallEvent(
        id: '2',
        matchId: 'm1',
        inningsNumber: 1,
        overNumber: 0,
        ballNumber: 1,
        batsmanId: 'b1',
        bowlerId: 'bowl1',
        runs: 4,
      );
      expect(four.displayText, '4');

      final wicket = BallEvent(
        id: '3',
        matchId: 'm1',
        inningsNumber: 1,
        overNumber: 0,
        ballNumber: 2,
        batsmanId: 'b1',
        bowlerId: 'bowl1',
        runs: 0,
        isWicket: true,
        wicketType: WicketType.bowled,
      );
      expect(wicket.displayText, 'W');
    });
  });
}
