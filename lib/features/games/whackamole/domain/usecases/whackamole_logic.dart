import 'dart:math';
import 'package:neo_game_suit/features/games/whackamole/domain/entities/whackamole_board.dart';

class WhackAMoleLogic {
  static final Random _random = Random();

  static WhackAMoleBoard whackMole(WhackAMoleBoard board, int index) {
    final hole = board.getHole(index);
    if (hole.state != HoleState.mole) {
      return board;
    }

    final newHoles = _deepCopyHoles(board.holes);
    newHoles[index] = newHoles[index].copyWith(state: HoleState.whacked);

    return board.copyWith(
      holes: newHoles,
      score: board.score + 10,
      totalWhacks: board.totalWhacks + 1,
    );
  }

  static WhackAMoleBoard update(WhackAMoleBoard board, DateTime now) {
    if (board.status != GameStatus.playing) {
      return board;
    }

    final elapsed = now.difference(board.startTime!);
    final timeLeft = board.difficulty.gameDuration - elapsed;

    if (timeLeft <= Duration.zero) {
      return board.copyWith(
        status: GameStatus.finished,
        timeLeft: Duration.zero,
      );
    }

    final newHoles = _deepCopyHoles(board.holes);
    int missed = board.missedMoles;

    // Update existing moles
    for (int i = 0; i < newHoles.length; i++) {
      if (newHoles[i].state == HoleState.mole && newHoles[i].appearTime != null) {
        final timeVisible = now.difference(newHoles[i].appearTime!);
        if (timeVisible >= newHoles[i].duration!) {
          newHoles[i] = newHoles[i].copyWith(state: HoleState.empty);
          missed++;
        }
      } else if (newHoles[i].state == HoleState.whacked) {
        // Keep whacked state for a short time
        newHoles[i] = newHoles[i].copyWith(state: HoleState.empty);
      }
    }

    // Spawn new moles
    final activeMoles = newHoles.where((h) => h.state == HoleState.mole).length;
    if (activeMoles < board.difficulty.maxActiveMoles) {
      final emptyHoles = newHoles.where((h) => h.state == HoleState.empty).toList();
      if (emptyHoles.isNotEmpty) {
        final numToSpawn = min(
          board.difficulty.maxActiveMoles - activeMoles,
          emptyHoles.length,
        );
        for (int i = 0; i < numToSpawn; i++) {
          if (_random.nextDouble() < 0.5) {
            // 50% chance to spawn each possible slot
            final emptyIndex = _random.nextInt(emptyHoles.length);
            final hole = emptyHoles[emptyIndex];
            final durationRange = board.difficulty.maxMoleDuration - board.difficulty.minMoleDuration;
            final duration = board.difficulty.minMoleDuration +
                Duration(milliseconds: _random.nextInt(durationRange.inMilliseconds));
            newHoles[hole.index] = newHoles[hole.index].copyWith(
              state: HoleState.mole,
              appearTime: now,
              duration: duration,
            );
            // Remove from empty list so we don't pick again
            emptyHoles.removeAt(emptyIndex);
          }
        }
      }
    }

    return board.copyWith(
      holes: newHoles,
      timeLeft: timeLeft,
      missedMoles: missed,
    );
  }

  static WhackAMoleBoard reset(DifficultySettings settings) {
    return WhackAMoleBoard.initial(settings);
  }

  static WhackAMoleBoard startGame(WhackAMoleBoard board) {
    return board.copyWith(
      status: GameStatus.playing,
      startTime: DateTime.now(),
    );
  }

  static List<Hole> _deepCopyHoles(List<Hole> holes) {
    return holes.map((h) => h.copyWith()).toList();
  }
}
