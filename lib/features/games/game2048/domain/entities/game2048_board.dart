import 'dart:math';
import 'package:equatable/equatable.dart';

const int _boardSize = 4;

class Game2048Board extends Equatable {
  final List<List<int>> board;
  final int score;
  final int bestScore;
  final bool gameOver;
  final bool isWin;

  const Game2048Board({
    required this.board,
    this.score = 0,
    this.bestScore = 0,
    this.gameOver = false,
    this.isWin = false,
  });

  factory Game2048Board.initial() {
    final board = List.generate(_boardSize, (_) => List.filled(_boardSize, 0));
    return Game2048Board(board: board);
  }

  int getTile(int row, int col) => board[row][col];

  Map<String, dynamic> toJson() {
    return {
      'board': board.map((row) => row.toList()).toList(),
      'score': score,
      'bestScore': bestScore,
      'gameOver': gameOver,
      'isWin': isWin,
    };
  }

  factory Game2048Board.fromJson(Map<String, dynamic> json) {
    final boardData = json['board'] as List<dynamic>;
    final parsedBoard = boardData.map((row) {
      return (row as List<dynamic>).map((e) => e as int).toList();
    }).toList();

    return Game2048Board(
      board: parsedBoard,
      score: json['score'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      gameOver: json['gameOver'] as bool? ?? false,
      isWin: json['isWin'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [board, score, bestScore, gameOver, isWin];
}
