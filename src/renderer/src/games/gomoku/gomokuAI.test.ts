
import { describe, it, expect } from 'vitest';
import { findBestMove } from './gomokuAI';
import type { Board, Player } from './gomokuLogic';

// Helper to create an empty board
const createBoard = (size = 15): Board => Array(size).fill(null).map(() => Array(size).fill(null));

describe('Gomoku AI', () => {

  it('AI should make a winning move (offensive test)', () => {
    const board = createBoard();
    const aiPlayer: Player = 'white';

    // Setup a scenario where AI has four in a row
    board[7][5] = aiPlayer;
    board[7][6] = aiPlayer;
    board[7][7] = aiPlayer;
    board[7][8] = aiPlayer;

    // The winning move should be at (7, 9) or (7, 4)
    const bestMove = findBestMove(board, aiPlayer);
    
    // Expect the AI to place the stone at the winning position
    const isWinningMove = (bestMove.row === 7 && bestMove.col === 9) || (bestMove.row === 7 && bestMove.col === 4);
    expect(isWinningMove).toBe(true);
  });

  it("AI should block opponent's winning move (defensive test)", () => {
    const board = createBoard();
    const aiPlayer: Player = 'white';
    const humanPlayer: Player = 'black';

    // Setup a scenario where the human has four in a row
    board[8][4] = humanPlayer;
    board[8][5] = humanPlayer;
    board[8][6] = humanPlayer;
    board[8][7] = humanPlayer;

    // The AI's blocking move must be at (8, 8) or (8, 3)
    const bestMove = findBestMove(board, aiPlayer);

    // Expect the AI to block the opponent
    const isBlockingMove = (bestMove.row === 8 && bestMove.col === 8) || (bestMove.row === 8 && bestMove.col === 3);
    expect(isBlockingMove).toBe(true);
  });

});
