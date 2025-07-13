
// src/renderer/src/games/chess/chessLogic.test.ts
import { describe, it, expect } from 'vitest';
import { isMoveValid, Board, Piece } from './chessLogic';

// Helper to create a board from a string layout
const createBoard = (layout: (string | null)[][]): Board => {
  return layout.map(row => 
    row.map(cell => {
      if (!cell) return null;
      const [colorChar, typeChar] = cell.split('');
      const color = colorChar === 'w' ? 'white' : 'black';
      const type = { p: 'pawn', r: 'rook', n: 'knight', b: 'bishop', q: 'queen', k: 'king' }[typeChar] as Piece['type'];
      return { type, color, hasMoved: false };
    })
  );
};

// --- Test Cases ---

describe('Chess Logic: isMoveValid', () => {

  describe('Pawn Moves', () => {
    it('should allow white pawn to move one step forward', () => {
      const board = createBoard([
        [null, null, null],
        [null, 'wp', null],
        [null, null, null],
      ]);
      expect(isMoveValid(board, [1, 1], [0, 1])).toBe(true);
    });

    it('should allow white pawn initial two-step move', () => {
        const boardLayout: (string | null)[][] = Array(8).fill(null).map(() => Array(8).fill(null));
        boardLayout[6][0] = 'wp'; // White pawn at a2
        const board = createBoard(boardLayout);
        expect(isMoveValid(board, [6, 0], [4, 0])).toBe(true); // a2 to a4
    });

    it('should block white pawn initial two-step move if blocked', () => {
        const boardLayout: (string | null)[][] = Array(8).fill(null).map(() => Array(8).fill(null));
        boardLayout[6][0] = 'wp';
        boardLayout[5][0] = 'bp'; // Blocker
        const board = createBoard(boardLayout);
        expect(isMoveValid(board, [6, 0], [4, 0])).toBe(false);
    });

    it('should allow black pawn to capture diagonally', () => {
        const boardLayout: (string | null)[][] = Array(8).fill(null).map(() => Array(8).fill(null));
        boardLayout[1][1] = 'bp'; // Black pawn at b7
        boardLayout[2][2] = 'wp'; // White pawn at c6
        const board = createBoard(boardLayout);
        expect(isMoveValid(board, [1, 1], [2, 2])).toBe(true);
    });

    it('should not allow pawn to move forward if blocked', () => {
        const board = createBoard([
            [null, 'bp', null],
            [null, 'wp', null],
            [null, null, null],
        ]);
        expect(isMoveValid(board, [1, 1], [0, 1])).toBe(false);
    });
  });

  describe('Rook Moves', () => {
    it('should allow rook to move horizontally', () => {
      const board = createBoard([
        ['wr', null, null, null, 'br'],
      ]);
      expect(isMoveValid(board, [0, 0], [0, 3])).toBe(true);
    });

    it('should not allow rook to move through pieces', () => {
      const board = createBoard([
        ['wr', 'wp', null, null, 'br'],
      ]);
      expect(isMoveValid(board, [0, 0], [0, 3])).toBe(false);
    });
  });

  describe('Knight Moves', () => {
    it('should allow knight to make L-shape moves', () => {
      const board = createBoard([
        [null, null, null, null, null],
        [null, null, 'wn', null, null],
        [null, null, null, null, null],
        [null, null, null, null, null],
        [null, null, null, null, null],
      ]);
      expect(isMoveValid(board, [1, 2], [0, 0])).toBe(true);
      expect(isMoveValid(board, [1, 2], [3, 3])).toBe(true);
    });
  });

  describe('Bishop Moves', () => {
    it('should allow bishop to move diagonally', () => {
        const board = createBoard([
            [null, null, 'wb', null, null],
            [null, null, null, null, null],
            [null, null, null, null, null],
            [null, null, null, null, 'bp'],
        ]);
        expect(isMoveValid(board, [0, 2], [2, 0])).toBe(true);
    });

    it('should not allow bishop to move through pieces', () => {
        const board = createBoard([
            [null, null, 'wb', null, null],
            [null, 'wp', null, null, null],
            [null, null, null, null, null],
        ]);
        expect(isMoveValid(board, [0, 2], [2, 0])).toBe(false);
    });
  });

  describe('Queen Moves', () => {
    it('should allow queen to move like a rook', () => {
        const board = createBoard([['wq', null, null, 'bp']]);
        expect(isMoveValid(board, [0, 0], [0, 2])).toBe(true);
    });

    it('should allow queen to move like a bishop', () => {
        const board = createBoard([
            ['wq', null, null],
            [null, null, null],
            [null, null, 'bp'],
        ]);
        expect(isMoveValid(board, [0, 0], [2, 2])).toBe(true);
    });
  });

  describe('King Moves', () => {
    it('should allow king to move one step in any direction', () => {
        const board = createBoard([
            [null, null, null],
            [null, 'wk', null],
            [null, null, null],
        ]);
        expect(isMoveValid(board, [1, 1], [0, 1])).toBe(true);
        expect(isMoveValid(board, [1, 1], [2, 2])).toBe(true);
    });

    it('should not allow king to move more than one step', () => {
        const board = createBoard([
            [null, null, null, null],
            [null, 'wk', null, null],
            [null, null, null, null],
            [null, null, null, null],
        ]);
        expect(isMoveValid(board, [1, 1], [3, 3])).toBe(false);
    });
  });

});
