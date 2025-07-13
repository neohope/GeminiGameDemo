import type { Board, Player } from './gomokuLogic';

// --- Constants ---
const boardSize = 15;
const WIN_SCORE = 1000000; // Score for a winning move (five in a row)

// Pattern scores for evaluation
const PATTERN_SCORES = {
  FIVE: WIN_SCORE,
  LIVE_FOUR: 10000,
  DEAD_FOUR: 1000,
  LIVE_THREE: 1000,
  DEAD_THREE: 100,
  LIVE_TWO: 100,
  DEAD_TWO: 10,
  LIVE_ONE: 10,
  DEAD_ONE: 1,
};

// --- Evaluation Logic ---

/**
 * Evaluates a "window" of 5 cells and returns a score based on the patterns found.
 * @param window An array of 5 cells.
 * @param player The current player ('black' or 'white').
 * @returns The score for this window.
 */
function evaluateWindow(window: (Player | null)[], player: Player): number {
  const opponent = player === 'black' ? 'white' : 'black';
  const playerCount = window.filter(p => p === player).length;
  const opponentCount = window.filter(p => p === opponent).length;
  const emptyCount = window.filter(p => p === null).length;

  if (playerCount > 0 && opponentCount > 0) return 0; // Mixed window is useless
  if (playerCount === 0 && opponentCount === 0) return 0; // All empty

  const count = playerCount > 0 ? playerCount : opponentCount;
  const isAI = playerCount > 0;

  switch (count) {
    case 5:
      return isAI ? PATTERN_SCORES.FIVE : -PATTERN_SCORES.FIVE;
    case 4:
      return isAI ? PATTERN_SCORES.LIVE_FOUR : -PATTERN_SCORES.LIVE_FOUR;
    case 3:
      return isAI ? PATTERN_SCORES.LIVE_THREE : -PATTERN_SCORES.LIVE_THREE;
    case 2:
      return isAI ? PATTERN_SCORES.LIVE_TWO : -PATTERN_SCORES.LIVE_TWO;
    case 1:
        return isAI ? PATTERN_SCORES.LIVE_ONE : -PATTERN_SCORES.LIVE_ONE;
    default:
      return 0;
  }
}

/**
 * Evaluates the entire board and returns a score.
 * A positive score favors the AI, a negative score favors the human.
 * @param board The game board.
 * @param aiPlayer The player for whom to evaluate the score.
 * @returns The total score of the board state.
 */
function evaluateBoard(board: Board, aiPlayer: Player): number {
  let totalScore = 0;
  const directions = [[1, 0], [0, 1], [1, 1], [1, -1]];

  for (let r = 0; r < boardSize; r++) {
    for (let c = 0; c < boardSize; c++) {
      // Evaluate horizontal
      if (c <= boardSize - 5) {
        const window = [board[r][c], board[r][c+1], board[r][c+2], board[r][c+3], board[r][c+4]];
        totalScore += evaluateWindow(window, aiPlayer);
      }
      // Evaluate vertical
      if (r <= boardSize - 5) {
        const window = [board[r][c], board[r+1][c], board[r+2][c], board[r+3][c], board[r+4][c]];
        totalScore += evaluateWindow(window, aiPlayer);
      }
      // Evaluate diagonal (down-right)
      if (r <= boardSize - 5 && c <= boardSize - 5) {
        const window = [board[r][c], board[r+1][c+1], board[r+2][c+2], board[r+3][c+3], board[r+4][c+4]];
        totalScore += evaluateWindow(window, aiPlayer);
      }
      // Evaluate anti-diagonal (up-right)
      if (r >= 4 && c <= boardSize - 5) {
        const window = [board[r][c], board[r-1][c+1], board[r-2][c+2], board[r-3][c+3], board[r-4][c+4]];
        totalScore += evaluateWindow(window, aiPlayer);
      }
    }
  }
  return totalScore;
}

/**
 * Generates a list of possible moves (empty cells) near existing pieces.
 * @param board The game board.
 * @returns An array of [row, col] for possible moves.
 */
function getPossibleMoves(board: Board): [number, number][] {
  const moves: [number, number][] = [];
  const hasPiece = Array(boardSize).fill(false).map(() => Array(boardSize).fill(false));
  const searchRadius = 2;

  for (let r = 0; r < boardSize; r++) {
    for (let c = 0; c < boardSize; c++) {
      if (board[r][c] === null) {
        // Check if there is any piece within the search radius
        let isNearPiece = false;
        for (let dr = -searchRadius; dr <= searchRadius; dr++) {
          for (let dc = -searchRadius; dc <= searchRadius; dc++) {
            if (dr === 0 && dc === 0) continue;
            const nr = r + dr;
            const nc = c + dc;
            if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize && board[nr][nc] !== null) {
              isNearPiece = true;
              break;
            }
          }
          if (isNearPiece) break;
        }
        if (isNearPiece) {
          moves.push([r, c]);
        }
      }
    }
  }
  // If no moves are found (e.g., first move of the game), return the center
  return moves.length > 0 ? moves : [[Math.floor(boardSize / 2), Math.floor(boardSize / 2)]];
}

// --- Minimax with Alpha-Beta Pruning ---

function minimax(board: Board, depth: number, alpha: number, beta: number, isMaximizingPlayer: boolean, aiPlayer: Player): number {
  const score = evaluateBoard(board, aiPlayer);

  // Terminal conditions
  if (Math.abs(score) >= WIN_SCORE || depth === 0) {
    return score;
  }

  const possibleMoves = getPossibleMoves(board);

  if (isMaximizingPlayer) {
    let maxEval = -Infinity;
    for (const [r, c] of possibleMoves) {
      board[r][c] = aiPlayer;
      const evalScore = minimax(board, depth - 1, alpha, beta, false, aiPlayer);
      board[r][c] = null; // backtrack
      maxEval = Math.max(maxEval, evalScore);
      alpha = Math.max(alpha, evalScore);
      if (beta <= alpha) {
        break; // Beta cutoff
      }
    }
    return maxEval;
  } else { // Minimizing player (human)
    let minEval = Infinity;
    const humanPlayer = aiPlayer === 'black' ? 'white' : 'black';
    for (const [r, c] of possibleMoves) {
      board[r][c] = humanPlayer;
      const evalScore = minimax(board, depth - 1, alpha, beta, true, aiPlayer);
      board[r][c] = null; // backtrack
      minEval = Math.min(minEval, evalScore);
      beta = Math.min(beta, evalScore);
      if (beta <= alpha) {
        break; // Alpha cutoff
      }
    }
    return minEval;
  }
}

// --- Main AI Function ---

export function findBestMove(board: Board, player: Player): { row: number, col: number } {
  let bestScore = -Infinity;
  let bestMove: { row: number, col: number } | null = null;
  const possibleMoves = getPossibleMoves(board);
  const searchDepth = 3; // Adjust depth for performance vs. strength

  for (const [r, c] of possibleMoves) {
    board[r][c] = player;
    const moveScore = minimax(board, searchDepth, -Infinity, Infinity, false, player);
    board[r][c] = null; // backtrack

    if (moveScore > bestScore) {
      bestScore = moveScore;
      bestMove = { row: r, col: c };
    }
  }

  if (bestMove) {
    console.log(`AI chose move (${bestMove.row}, ${bestMove.col}) with score: ${bestScore}`);
    return bestMove;
  } else {
    // Fallback if no move is found (should be rare)
    return { row: Math.floor(boardSize / 2), col: Math.floor(boardSize / 2) };
  }
}