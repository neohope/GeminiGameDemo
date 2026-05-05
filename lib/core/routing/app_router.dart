import 'package:go_router/go_router.dart';
import 'package:neo_game_suit/core/constants/app_constants.dart';
import 'package:neo_game_suit/features/home/presentation/pages/home_page.dart';
import 'package:neo_game_suit/features/games/gomoku/presentation/pages/gomoku_page.dart';
import 'package:neo_game_suit/features/games/chinese_chess/presentation/pages/chinese_chess_page.dart';
import 'package:neo_game_suit/features/games/go/presentation/pages/go_page.dart';
import 'package:neo_game_suit/features/games/chess/presentation/pages/chess_page.dart';
import 'package:neo_game_suit/features/games/sudoku/presentation/pages/sudoku_page.dart';
import 'package:neo_game_suit/features/games/game2048/presentation/pages/game2048_page.dart';
import 'package:neo_game_suit/features/games/snake/presentation/pages/snake_page.dart';
import 'package:neo_game_suit/features/games/tictactoe/presentation/pages/tictactoe_page.dart';
import 'package:neo_game_suit/features/games/reversi/presentation/pages/reversi_page.dart';
import 'package:neo_game_suit/features/games/huarongdao/presentation/pages/huarongdao_page.dart';
import 'package:neo_game_suit/features/games/minesweeper/presentation/pages/minesweeper_page.dart';
import 'package:neo_game_suit/features/games/whackamole/presentation/pages/whackamole_page.dart';
import 'package:neo_game_suit/features/games/flappybird/presentation/pages/flappybird_page.dart';
import 'package:neo_game_suit/features/games/tetris/presentation/pages/tetris_page.dart';
import 'package:neo_game_suit/features/games/dino/presentation/pages/dino_page.dart';
import 'package:neo_game_suit/features/games/fall100/presentation/pages/fall100_page.dart';
import 'package:neo_game_suit/features/games/breakout/presentation/pages/breakout_page.dart';

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
    GoRoute(
      path: AppConstants.game2048Path,
      name: 'game2048',
      builder: (context, state) => const Game2048Page(),
    ),
    GoRoute(
      path: AppConstants.snakePath,
      name: 'snake',
      builder: (context, state) => const SnakePage(),
    ),
    GoRoute(
      path: AppConstants.ticTacToePath,
      name: 'tictactoe',
      builder: (context, state) => const TicTacToePage(),
    ),
    GoRoute(
      path: AppConstants.reversiPath,
      name: 'reversi',
      builder: (context, state) => const ReversiPage(),
    ),
    GoRoute(
      path: AppConstants.huarongdaoPath,
      name: 'huarongdao',
      builder: (context, state) => const HuarongdaoPage(),
    ),
    GoRoute(
      path: AppConstants.minesweeperPath,
      name: 'minesweeper',
      builder: (context, state) => const MinesweeperPage(),
    ),
    GoRoute(
      path: AppConstants.whackAMolePath,
      name: 'whackamole',
      builder: (context, state) => const WhackAMolePage(),
    ),
    GoRoute(
      path: AppConstants.flappyBirdPath,
      name: 'flappybird',
      builder: (context, state) => const FlappyBirdPage(),
    ),
    GoRoute(
      path: AppConstants.tetrisPath,
      name: 'tetris',
      builder: (context, state) => const TetrisPage(),
    ),
    GoRoute(
      path: AppConstants.dinoPath,
      name: 'dino',
      builder: (context, state) => const DinoPage(),
    ),
    GoRoute(
      path: AppConstants.fall100Path,
      name: 'fall100',
      builder: (context, state) => const Fall100Page(),
    ),
    GoRoute(
      path: AppConstants.breakoutPath,
      name: 'breakout',
      builder: (context, state) => const BreakoutPage(),
    ),
  ],
);
