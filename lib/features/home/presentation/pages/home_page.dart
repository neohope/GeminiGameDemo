import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/shared/widgets/responsive_scaffold.dart';
import 'package:neo_game_suit/features/home/presentation/widgets/game_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: AppConstants.appName,
      body: _buildGameGrid(context),
    );
  }

  Widget _buildGameGrid(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);
    final crossAxisCount = switch (screenSize) {
      ScreenSize.small => 2,
      ScreenSize.medium => 3,
      ScreenSize.large => 5,
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          GameCard(
            icon: '⚫',
            title: '五子棋',
            subtitle: 'Gomoku',
            onTap: () => context.go(AppConstants.gomokuPath),
          ),
          GameCard(
            icon: '帥',
            title: '中国象棋',
            subtitle: 'Chinese Chess',
            onTap: () => context.go(AppConstants.chineseChessPath),
          ),
          GameCard(
            icon: '弈',
            title: '围棋',
            subtitle: 'Go',
            onTap: () => context.go(AppConstants.goPath),
          ),
          GameCard(
            icon: '♔',
            title: '国际象棋',
            subtitle: 'Chess',
            onTap: () => context.go(AppConstants.chessPath),
          ),
          GameCard(
            icon: '🔢',
            title: '数独',
            subtitle: 'Sudoku',
            onTap: () => context.go(AppConstants.sudokuPath),
          ),
        ],
      ),
    );
  }
}
