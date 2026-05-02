import 'package:flutter/material.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';
import 'package:neo_game_suit/features/games/huarongdao/domain/entities/huarongdao_board.dart';

class HuarongdaoBoardWidget extends StatelessWidget {
  final HuarongdaoBoard board;
  final Function(Piece piece, int dRow, int dCol) onMovePiece;

  const HuarongdaoBoardWidget({
    super.key,
    required this.board,
    required this.onMovePiece,
  });

  @override
  Widget build(BuildContext context) {
    final boardSize = ResponsiveLayout.boardSize(context, maxSize: 450);
    final cellSize = boardSize / 4;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: boardSize,
          height: boardSize * 5 / 4,
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF5D2906), width: 4),
          ),
          child: Stack(
            children: [
              _buildGrid(boardSize, cellSize),
              _buildPieces(boardSize, cellSize),
              _buildExitArea(boardSize, cellSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(double boardSize, double cellSize) {
    final children = <Widget>[];
    for (int i = 1; i < 4; i++) {
      children.add(
        Positioned(
          left: i * cellSize,
          top: 0,
          child: Container(
            width: 1,
            height: cellSize * 5,
            color: const Color(0xFF5D2906).withValues(alpha: 0.3),
          ),
        ),
      );
    }
    for (int i = 1; i < 5; i++) {
      children.add(
        Positioned(
          left: 0,
          top: i * cellSize,
          child: Container(
            width: boardSize,
            height: 1,
            color: const Color(0xFF5D2906).withValues(alpha: 0.3),
          ),
        ),
      );
    }
    return Stack(children: children);
  }

  Widget _buildExitArea(double boardSize, double cellSize) {
    return Positioned(
      left: cellSize,
      top: cellSize * 4,
      child: Container(
        width: cellSize * 2,
        height: cellSize,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFFD700), width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            '出口',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieces(double boardSize, double cellSize) {
    final children = <Widget>[];
    for (final piece in board.pieces) {
      children.add(
        _DraggablePiece(
          piece: piece,
          cellSize: cellSize,
          onMovePiece: onMovePiece,
        ),
      );
    }
    return Stack(children: children);
  }
}

class _DraggablePiece extends StatefulWidget {
  final Piece piece;
  final double cellSize;
  final Function(Piece piece, int dRow, int dCol) onMovePiece;

  const _DraggablePiece({
    required this.piece,
    required this.cellSize,
    required this.onMovePiece,
  });

  @override
  State<_DraggablePiece> createState() => _DraggablePieceState();
}

class _DraggablePieceState extends State<_DraggablePiece> {
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final width = widget.cellSize * widget.piece.width;
    final height = widget.cellSize * widget.piece.height;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      left: widget.piece.col * widget.cellSize + _dragOffset.dx,
      top: widget.piece.row * widget.cellSize + _dragOffset.dy,
      child: GestureDetector(
        onPanStart: (details) {
          _dragOffset = Offset.zero;
        },
        onPanUpdate: (details) {
          setState(() {
            _dragOffset += details.delta;
          });
        },
        onPanEnd: (details) {
          final dx = _dragOffset.dx;
          final dy = _dragOffset.dy;
          int dCol = 0;
          int dRow = 0;

          if (dx.abs() > dy.abs()) {
            if (dx.abs() > widget.cellSize * 0.3) {
              dCol = dx > 0 ? 1 : -1;
            }
          } else {
            if (dy.abs() > widget.cellSize * 0.3) {
              dRow = dy > 0 ? 1 : -1;
            }
          }

          if (dCol != 0 || dRow != 0) {
            widget.onMovePiece(widget.piece, dRow, dCol);
          }

          setState(() {
            _dragOffset = Offset.zero;
          });
        },
        child: Container(
          width: width - 4,
          height: height - 4,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: widget.piece.type == PieceType.caocao
                ? const Color(0xFFFF6B6B)
                : widget.piece.type == PieceType.soldier
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFFFFD166),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.piece.type == PieceType.caocao
                  ? const Color(0xFFCC5555)
                  : widget.piece.type == PieceType.soldier
                      ? const Color(0xFF3BA99C)
                      : const Color(0xFFCCAA50),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              widget.piece.name,
              style: TextStyle(
                fontSize: widget.cellSize * 0.35,
                fontWeight: FontWeight.bold,
                color: widget.piece.type == PieceType.caocao
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
