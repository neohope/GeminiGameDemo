import 'package:go_router/go_router.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/features/home/presentation/pages/home_page.dart';
import 'package:neo_game_suit/features/games/gomoku/presentation/pages/gomoku_page.dart';
import 'package:neo_game_suit/features/games/chinese_chess/presentation/pages/chinese_chess_page.dart';
import 'package:neo_game_suit/features/games/go/presentation/pages/go_page.dart';
import 'package:neo_game_suit/features/games/chess/presentation/pages/chess_page.dart';
import 'package:neo_game_suit/features/games/sudoku/presentation/pages/sudoku_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.homePath,
  routes: [
    GoRoute(
      path: AppConstants.homePath,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppConstants.gomokuPath,
      name: 'gomoku',
      builder: (context, state) => const GomokuPage(),
    ),
    GoRoute(
      path: AppConstants.chineseChessPath,
      name: 'chinese_chess',
      builder: (context, state) => const ChineseChessPage(),
    ),
    GoRoute(
      path: AppConstants.goPath,
      name: 'go',
      builder: (context, state) => const GoPage(),
    ),
    GoRoute(
      path: AppConstants.chessPath,
      name: 'chess',
      builder: (context, state) => const ChessPage(),
    ),
    GoRoute(
      path: AppConstants.sudokuPath,
      name: 'sudoku',
      builder: (context, state) => const SudokuPage(),
    ),
  ],
);
