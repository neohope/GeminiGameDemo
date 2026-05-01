class AppConstants {
  static const String appName = 'Neo Game Suite';

  // 路由路径
  static const String homePath = '/';
  static const String gomokuPath = '/gomoku';
  static const String chineseChessPath = '/chinese_chess';
  static const String goPath = '/go';
  static const String chessPath = '/chess';
  static const String sudokuPath = '/sudoku';
}

enum GameMode {
  hvh, // 人vs人
  hva, // 人vsAI
}
