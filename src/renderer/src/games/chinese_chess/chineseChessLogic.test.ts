import { isValidMove, isKingInCheck, isGameOver, Piece, Player, Board } from './chineseChessLogic';

import { describe, it, expect, beforeEach } from 'vitest';

describe('Chinese Chess Capture Logic', () => {
  let initialBoard: Board;

  beforeEach(() => {
    // A simplified board for testing captures
    initialBoard = [
      { id: 1, x: 4, y: 0, text: '帥', color: 'red' },
      { id: 2, x: 4, y: 9, text: '將', color: 'black' },
      { id: 3, x: 4, y: 1, text: '車', color: 'red' }, // Red Chariot
      { id: 4, x: 4, y: 2, text: '卒', color: 'black' }, // Black Pawn
      { id: 5, x: 0, y: 0, text: '車', color: 'black' }, // Black Chariot
      { id: 6, x: 0, y: 1, text: '兵', color: 'red' }, // Red Pawn
    ];
  });

  it('should allow a red chariot to capture a black pawn', () => {
    const redChariot = initialBoard.find(p => p.id === 3)!; // Red Chariot at (4,1)
    const blackPawn = initialBoard.find(p => p.id === 4)!; // Black Pawn at (4,2)

    // Simulate the move in ChineseChessBoard.tsx's movePiece logic
    const newPieces = initialBoard.filter(p => !(p.x === blackPawn.x && p.y === blackPawn.y)).map(p => p.id === redChariot.id ? { ...p, x: blackPawn.x, y: blackPawn.y } : p);

    // The black pawn should no longer be on the board
    expect(newPieces.some(p => p.id === blackPawn.id)).toBe(false);
    // The red chariot should be at the new position
    expect(newPieces.find(p => p.id === redChariot.id)).toEqual(expect.objectContaining({ x: blackPawn.x, y: blackPawn.y }));
  });

  it('should not allow a piece to capture its own color', () => {
    const redChariot = initialBoard.find(p => p.id === 3)!; // Red Chariot at (4,1)
    const redGeneral = initialBoard.find(p => p.id === 1)!; // Red General at (4,0)

    // isValidMove should return false if trying to move to a square with own color
    const canMove = isValidMove(redChariot, redGeneral.x, redGeneral.y, initialBoard, false);
    expect(canMove).toBe(false);
  });

  it('should allow a black chariot to capture a red pawn', () => {
    const blackChariot = initialBoard.find(p => p.id === 5)!; // Black Chariot at (0,0)
    const redPawn = initialBoard.find(p => p.id === 6)!; // Red Pawn at (0,1)

    const newPieces = initialBoard.filter(p => !(p.x === redPawn.x && p.y === redPawn.y)).map(p => p.id === blackChariot.id ? { ...p, x: redPawn.x, y: redPawn.y } : p);

    expect(newPieces.some(p => p.id === redPawn.id)).toBe(false);
    expect(newPieces.find(p => p.id === blackChariot.id)).toEqual(expect.objectContaining({ x: redPawn.x, y: redPawn.y }));
  });

  it('should handle cannon capture over a single piece', () => {
    const cannonBoard: Board = [
      { id: 1, x: 4, y: 0, text: '帥', color: 'red' },
      { id: 2, x: 4, y: 9, text: '將', color: 'black' },
      { id: 3, x: 4, y: 2, text: '炮', color: 'red' }, // Red Cannon
      { id: 4, x: 4, y: 4, text: '卒', color: 'black' }, // Black Pawn (screen)
      { id: 5, x: 4, y: 6, text: '車', color: 'black' }, // Black Chariot (target)
    ];
    const redCannon = cannonBoard.find(p => p.id === 3)!;
    const blackPawnScreen = cannonBoard.find(p => p.id === 4)!;
    const blackChariotTarget = cannonBoard.find(p => p.id === 5)!;

    // Cannon should be able to capture over one piece
    const canCapture = isValidMove(redCannon, blackChariotTarget.x, blackChariotTarget.y, cannonBoard, false);
    expect(canCapture).toBe(true);

    // Simulate the capture
    const newPieces = cannonBoard.filter(p => !(p.x === blackChariotTarget.x && p.y === blackChariotTarget.y)).map(p => p.id === redCannon.id ? { ...p, x: blackChariotTarget.x, y: blackChariotTarget.y } : p);

    expect(newPieces.some(p => p.id === blackChariotTarget.id)).toBe(false);
    expect(newPieces.find(p => p.id === redCannon.id)).toEqual(expect.objectContaining({ x: blackChariotTarget.x, y: blackChariotTarget.y }));
    // The screen piece should still be there
    expect(newPieces.some(p => p.id === blackPawnScreen.id)).toBe(true);
  });

  it('should not allow cannon to capture without a screen piece', () => {
    const cannonBoard: Board = [
      { id: 1, x: 4, y: 0, text: '帥', color: 'red' },
      { id: 2, x: 4, y: 9, text: '將', color: 'black' },
      { id: 3, x: 4, y: 2, text: '炮', color: 'red' }, // Red Cannon
      { id: 5, x: 4, y: 6, text: '車', color: 'black' }, // Black Chariot (target)
    ];
    const redCannon = cannonBoard.find(p => p.id === 3)!;
    const blackChariotTarget = cannonBoard.find(p => p.id === 5)!;

    // Cannon should not be able to capture without a screen piece
    const canCapture = isValidMove(redCannon, blackChariotTarget.x, blackChariotTarget.y, cannonBoard, false);
    expect(canCapture).toBe(false);
  });

  it('should not allow cannon to capture over multiple pieces', () => {
    const cannonBoard: Board = [
      { id: 1, x: 4, y: 0, text: '帥', color: 'red' },
      { id: 2, x: 4, y: 9, text: '將', color: 'black' },
      { id: 3, x: 4, y: 2, text: '炮', color: 'red' }, // Red Cannon
      { id: 4, x: 4, y: 3, text: '卒', color: 'black' }, // Black Pawn (screen 1)
      { id: 6, x: 4, y: 4, text: '馬', color: 'red' }, // Red Horse (screen 2)
      { id: 5, x: 4, y: 6, text: '車', color: 'black' }, // Black Chariot (target)
    ];
    const redCannon = cannonBoard.find(p => p.id === 3)!;
    const blackChariotTarget = cannonBoard.find(p => p.id === 5)!;

    // Cannon should not be able to capture over multiple pieces
    const canCapture = isValidMove(redCannon, blackChariotTarget.x, blackChariotTarget.y, cannonBoard, false);
    expect(canCapture).toBe(false);
  });
});
