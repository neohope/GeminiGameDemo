import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/games/tictactoe/domain/entities/tictactoe_board.dart';
import 'package:neo_game_suit/features/games/tictactoe/presentation/providers/tictactoe_provider.dart';
import 'package:neo_game_suit/features/games/tictactoe/presentation/widgets/tictactoe_board_widget.dart';

class TicTacToePage extends ConsumerWidget {
  const TicTacToePage({super.key});

  // Helper to get dropdown value
  String _getDropdownValue(GameMode mode, Player humanPlayer) {
    if (mode == GameMode.hvh) {
      return 'hvh';
    } else if (humanPlayer == Player.x) {
      return 'hva_x';
    } else {
      return 'hva_o';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(ticTacToeProvider);
    final notifier = ref.read(ticTacToeProvider.notifier);
    final canChangeMode = !notifier.hasGameStarted && board.status == GameStatus.playing;

    return ResponsiveScaffold(
      title: '井字棋',
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildStatus(context, board),
          Expanded(
            child: TicTacToeBoardWidget(
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
          _buildControlBar(context, notifier, board, canChangeMode),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context, TicTacToeBoard board) {
    String text;
    if (board.status == GameStatus.playing) {
      if (board.mode == GameMode.hva) {
        final isHumanTurn = board.currentPlayer == board.humanPlayer;
        text = isHumanTurn ? '你的回合 (${board.currentPlayer == Player.x ? 'X' : 'O'})' : 'AI 思考中...';
      } else {
        text = '${board.currentPlayer == Player.x ? 'X' : 'O'} 的回合';
      }
    } else if (board.status == GameStatus.xWon) {
      text = 'X 获胜！';
    } else if (board.status == GameStatus.oWon) {
      text = 'O 获胜！';
    } else {
      text = '平局！';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, TicTacToeBoard board, TicTacToeNotifier notifier) {
    String message;
    if (board.status == GameStatus.xWon) {
      message = 'X 获胜！';
    } else if (board.status == GameStatus.oWon) {
      message = 'O 获胜！';
    } else {
      message = '平局！';
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

  Widget _buildControlBar(BuildContext context, TicTacToeNotifier notifier, TicTacToeBoard board, bool canChangeMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          DropdownButton<String>(
            value: _getDropdownValue(board.mode, board.humanPlayer),
            items: const [
              DropdownMenuItem(
                value: 'hvh',
                child: Text('双人对战'),
              ),
              DropdownMenuItem(
                value: 'hva_x',
                child: Text('人机对战 - 执 X'),
              ),
              DropdownMenuItem(
                value: 'hva_o',
                child: Text('人机对战 - 执 O'),
              ),
            ],
            onChanged: canChangeMode
                ? (value) {
                    if (value == 'hvh') {
                      notifier.setModeAndPlayer(GameMode.hvh, Player.x);
                    } else if (value == 'hva_x') {
                      notifier.setModeAndPlayer(GameMode.hva, Player.x);
                    } else if (value == 'hva_o') {
                      notifier.setModeAndPlayer(GameMode.hva, Player.o);
                    }
                  }
                : null,
          ),
          ElevatedButton.icon(
            onPressed: () => notifier.reset(mode: board.mode, humanPlayer: board.humanPlayer),
            icon: const Icon(Icons.refresh),
            label: const Text('新游戏'),
          ),
        ],
      ),
    );
  }
}
