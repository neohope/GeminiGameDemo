
import { Board, Player, isValidMove } from './chineseChessLogic';

const pieceValues = {
  '車': 90, '馬': 40, '相': 20, '仕': 20, '帥': 10000,
  '炮': 45, '兵': 10,
  '象': 20, '士': 20, '將': 10000,
  '砲': 45, '卒': 10,
};

function evaluate(board: Board, player: Player): number {
  let score = 0;
  for (const piece of board) {
    const value = pieceValues[piece.text] || 0;
    if (piece.color === player) {
      score += value;
    } else {
      score -= value;
    }
  }
  return score;
}

function minimax(board: Board, depth: number, isMaximizing: boolean, alpha: number, beta: number, player: Player): number {
  if (depth === 0) {
    return evaluate(board, player);
  }

  const opponent: Player = player === 'red' ? 'black' : 'red';
  const piecesToMove = board.filter(p => p.color === (isMaximizing ? player : opponent));

  if (isMaximizing) {
    let maxEval = -Infinity;
    for (const piece of piecesToMove) {
      // Generate all possible moves for the piece (this is a simplification)
      for (let y = 0; y < 10; y++) {
        for (let x = 0; x < 9; x++) {
          if (isValidMove(piece, x, y, board, false)) {
            const tempBoard = board.filter(p => !(p.x === x && p.y === y)).map(p => p.id === piece.id ? { ...p, x, y } : p);
            const evaluation = minimax(tempBoard, depth - 1, false, alpha, beta, player);
            maxEval = Math.max(maxEval, evaluation);
            alpha = Math.max(alpha, evaluation);
            if (beta <= alpha) return maxEval; // Pruning
          }
        }
      }
    }
    return maxEval;
  } else {
    let minEval = Infinity;
    for (const piece of piecesToMove) {
      for (let y = 0; y < 10; y++) {
        for (let x = 0; x < 9; x++) {
          if (isValidMove(piece, x, y, board, false)) {
            const tempBoard = board.filter(p => !(p.x === x && p.y === y)).map(p => p.id === piece.id ? { ...p, x, y } : p);
            const evaluation = minimax(tempBoard, depth - 1, true, alpha, beta, player);
            minEval = Math.min(minEval, evaluation);
            beta = Math.min(beta, evaluation);
            if (beta <= alpha) return minEval; // Pruning
          }
        }
      }
    }
    return minEval;
  }
}

export function findBestMove(board: Board, player: Player): { piece: any, toX: number, toY: number } | null {
  let bestVal = -Infinity;
  let bestMove: { piece: any, toX: number, toY: number } | null = null;

  const piecesToMove = board.filter(p => p.color === player);

  for (const piece of piecesToMove) {
    for (let y = 0; y < 10; y++) {
      for (let x = 0; x < 9; x++) {
        if (isValidMove(piece, x, y, board, false)) {
          const tempBoard = board.filter(p => !(p.x === x && p.y === y)).map(p => p.id === piece.id ? { ...p, x, y } : p);
          const moveVal = minimax(tempBoard, 2, false, -Infinity, Infinity, player); // Depth of 2 is a good start for performance
          if (moveVal > bestVal) {
            bestMove = { piece, toX: x, toY: y };
            bestVal = moveVal;
          }
        }
      }
    }
  }
  return bestMove;
}
