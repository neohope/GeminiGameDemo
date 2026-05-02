import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/reversi/domain/entities/reversi_board.dart';
import 'package:neo_game_suit/features/games/reversi/domain/usecases/reversi_logic.dart';
import 'package:neo_game_suit/features/games/reversi/presentation/providers/reversi_provider.dart';
import 'package:neo_game_suit/features/games/reversi/presentation/widgets/reversi_board_widget.dart';

class ReversiPage extends ConsumerWidget {
  const ReversiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(reversiProvider);
    final notifier = ref.read(reversiProvider.notifier);

    return ResponsiveScaffold(
      title: '黑白棋',
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildScoreBoard(context, board),
          const SizedBox(height: 8),
          _buildStatus(context, board),
          Expanded(
            child: ReversiBoardWidget(
              board: board,
              onTileTap: (row, col) {
                if (board.mode == GameMode.hva && board.currentPlayer != board.humanPlayer) {
                  return;
                }
                notifier.makeMove(row, col);
              },
            ),
          ),
          if (board.status != GameStatus.playing) _buildGameOver(context, board, notifier),
          const SizedBox(height: 16),
          _buildControlBar(context, notifier, board),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildScoreBoard(BuildContext context, ReversiBoard board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ScoreBox(
            label: 'Black',
            score: board.blackScore,
            isCurrent: board.currentPlayer == Player.black,
            isBlack: true,
          ),
          const SizedBox(width: 16),
          _ScoreBox(
            label: 'White',
            score: board.whiteScore,
            isCurrent: board.currentPlayer == Player.white,
            isBlack: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context, ReversiBoard board) {
    String text;
    if (board.status == GameStatus.playing) {
      final validMoves = ReversiLogic.getValidMoves(board, board.currentPlayer);
      if (validMoves.isEmpty) {
        text = '${board.currentPlayer == Player.black ? 'Black' : 'White'} has no moves!';
      } else if (board.mode == GameMode.hva) {
        final isHumanTurn = board.currentPlayer == board.humanPlayer;
        text = isHumanTurn ? 'Your Turn' : 'AI Thinking...';
      } else {
        text = '${board.currentPlayer == Player.black ? 'Black' : 'White'}\'s Turn';
      }
    } else if (board.status == GameStatus.blackWon) {
      text = 'Black Wins!';
    } else if (board.status == GameStatus.whiteWon) {
      text = 'White Wins!';
    } else {
      text = 'Draw!';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, ReversiBoard board, ReversiNotifier notifier) {
    String message;
    if (board.status == GameStatus.blackWon) {
      message = 'Black Wins!';
    } else if (board.status == GameStatus.whiteWon) {
      message = 'White Wins!';
    } else {
      message = 'It\'s a Draw!';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, ReversiNotifier notifier, ReversiBoard board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showModeSelection(context, notifier),
                icon: const Icon(Icons.settings),
                label: const Text('Game Mode'),
              ),
              ElevatedButton.icon(
                onPressed: () => notifier.reset(mode: board.mode, humanPlayer: board.humanPlayer),
                icon: const Icon(Icons.refresh),
                label: const Text('New Game'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showModeSelection(BuildContext context, ReversiNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Game Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Human vs Human'),
              onTap: () {
                notifier.reset(mode: GameMode.hvh);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Human vs AI (Play as Black)'),
              onTap: () {
                notifier.reset(mode: GameMode.hva, humanPlayer: Player.black);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Human vs AI (Play as White)'),
              onTap: () {
                notifier.reset(mode: GameMode.hva, humanPlayer: Player.white);
                // AI plays first as black
                Future.delayed(const Duration(milliseconds: 500), () {
                  notifier.makeMove(3, 4); // Or another valid opening
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int score;
  final bool isCurrent;
  final bool isBlack;

  const _ScoreBox({
    required this.label,
    required this.score,
    required this.isCurrent,
    required this.isBlack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isBlack ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent
            ? Border.all(color: const Color(0xFFE94560), width: 3)
            : Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBlack ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: isBlack ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
