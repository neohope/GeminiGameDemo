import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';

class SudokuKeypad extends StatelessWidget {
  final bool enabled;
  final ValueChanged<int> onNumberPressed;
  final VoidCallback onDeletePressed;

  const SudokuKeypad({
    super.key,
    required this.enabled,
    required this.onNumberPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);
    final isSmall = screenSize == ScreenSize.small;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: isSmall ? 5 : 10,
          shrinkWrap: true,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: isSmall ? 1.5 : 1,
          children: [
            for (int i = 1; i <= 9; i++)
              ElevatedButton(
                onPressed: enabled ? () => onNumberPressed(i) : null,
                child: Text(i.toString(), style: const TextStyle(fontSize: 18)),
              ),
            ElevatedButton.icon(
              onPressed: enabled ? onDeletePressed : null,
              icon: const Icon(Icons.backspace),
              label: isSmall ? const Text('') : const Text('删除'),
            ),
          ],
        ),
      ),
    );
  }
}
