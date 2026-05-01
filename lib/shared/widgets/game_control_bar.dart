import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';

class GameControlBar extends StatelessWidget {
  final GameMode gameMode;
  final ValueChanged<GameMode> onGameModeChanged;
  final VoidCallback onUndo;
  final VoidCallback onSave;
  final VoidCallback onLoad;
  final VoidCallback onReset;
  final bool canUndo;
  final bool canSave;
  final bool hasSave;
  final bool isGameOver;
  final List<Widget>? extraActions;

  const GameControlBar({
    super.key,
    required this.gameMode,
    required this.onGameModeChanged,
    required this.onUndo,
    required this.onSave,
    required this.onLoad,
    required this.onReset,
    this.canUndo = true,
    this.canSave = true,
    this.hasSave = false,
    this.isGameOver = false,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveLayout.isSmallScreen(context);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: isSmallScreen
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeSelector(),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: _buildButtons(context),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeSelector(),
                  const SizedBox(width: 16),
                  ..._buildButtons(context),
                ],
              ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('模式:'),
        const SizedBox(width: 8),
        DropdownButton<GameMode>(
          value: gameMode,
          items: const [
            DropdownMenuItem(
              value: GameMode.hvh,
              child: Text('人vs人'),
            ),
            DropdownMenuItem(
              value: GameMode.hva,
              child: Text('人vsAI'),
            ),
          ],
          onChanged: isGameOver ? null : (value) => value != null ? onGameModeChanged(value) : null,
        ),
      ],
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final buttons = <Widget>[
      ElevatedButton.icon(
        onPressed: (canUndo && !isGameOver) ? onUndo : null,
        icon: const Icon(Icons.undo),
        label: const Text('悔棋'),
      ),
      ElevatedButton.icon(
        onPressed: (canSave && !isGameOver) ? onSave : null,
        icon: const Icon(Icons.save),
        label: const Text('存档'),
      ),
      ElevatedButton.icon(
        onPressed: hasSave ? onLoad : null,
        icon: const Icon(Icons.folder_open),
        label: const Text('读档'),
      ),
      ElevatedButton.icon(
        onPressed: onReset,
        icon: const Icon(Icons.refresh),
        label: const Text('重置'),
      ),
    ];

    if (extraActions != null) {
      buttons.addAll(extraActions!);
    }

    return buttons;
  }
}
