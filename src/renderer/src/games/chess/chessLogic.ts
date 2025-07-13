
// src/renderer/src/games/chess/chessLogic.ts

export type Player = 'white' | 'black';
export type PieceType = 'pawn' | 'rook' | 'knight' | 'bishop' | 'queen' | 'king';
export type Piece = { type: PieceType; color: Player; hasMoved?: boolean };
export type Board = (Piece | null)[][];
export type Move = { from: [number, number]; to: [number, number] };

const boardSize = 8;

function isInsideBoard(row: number, col: number): boolean {
  return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
}

function getPiece(board: Board, row: number, col: number): Piece | null {
  if (!isInsideBoard(row, col)) return null;
  return board[row][col];
}

// --- Piece-specific move validation ---

function isValidPawnMove(board: Board, from: [number, number], to: [number, number]): boolean {
  const [fromRow, fromCol] = from;
  const [toRow, toCol] = to;
  const piece = getPiece(board, fromRow, fromCol);
  if (!piece) return false;

  const direction = piece.color === 'white' ? -1 : 1;
  const startRow = piece.color === 'white' ? 6 : 1;

  // Standard 1-step move
  if (fromCol === toCol && !getPiece(board, toRow, toCol) && toRow === fromRow + direction) {
    return true;
  }

  // Initial 2-step move
  if (fromCol === toCol && !getPiece(board, toRow, toCol) && fromRow === startRow && toRow === fromRow + 2 * direction && !getPiece(board, fromRow + direction, fromCol)) {
    return true;
  }

  // Capture move
  if (Math.abs(fromCol - toCol) === 1 && toRow === fromRow + direction) {
    const targetPiece = getPiece(board, toRow, toCol);
    return targetPiece !== null && targetPiece.color !== piece.color;
  }

  // En-passant (simplified version, needs lastMove context)
  // This would require passing the last move into isValidMove, skipping for now.

  return false;
}

function isValidRookMove(board: Board, from: [number, number], to: [number, number]): boolean {
  const [fromRow, fromCol] = from;
  const [toRow, toCol] = to;

  if (fromRow !== toRow && fromCol !== toCol) return false; // Not a straight line

  const stepRow = fromRow === toRow ? 0 : (toRow > fromRow ? 1 : -1);
  const stepCol = fromCol === toCol ? 0 : (toCol > fromCol ? 1 : -1);
  let currentRow = fromRow + stepRow;
  let currentCol = fromCol + stepCol;

  while (currentRow !== toRow || currentCol !== toCol) {
    if (getPiece(board, currentRow, currentCol)) return false; // Path is blocked
    currentRow += stepRow;
    currentCol += stepCol;
  }

  return true;
}

function isValidKnightMove(from: [number, number], to: [number, number]): boolean {
  const [fromRow, fromCol] = from;
  const [toRow, toCol] = to;
  const dRow = Math.abs(toRow - fromRow);
  const dCol = Math.abs(toCol - fromCol);
  return (dRow === 2 && dCol === 1) || (dRow === 1 && dCol === 2);
}

function isValidBishopMove(board: Board, from: [number, number], to: [number, number]): boolean {
  const [fromRow, fromCol] = from;
  const [toRow, toCol] = to;

  if (Math.abs(toRow - fromRow) !== Math.abs(toCol - fromCol)) return false; // Not a diagonal

  const stepRow = toRow > fromRow ? 1 : -1;
  const stepCol = toCol > fromCol ? 1 : -1;
  let currentRow = fromRow + stepRow;
  let currentCol = fromCol + stepCol;

  while (currentRow !== toRow || currentCol !== toCol) {
    if (getPiece(board, currentRow, currentCol)) return false; // Path is blocked
    currentRow += stepRow;
    currentCol += stepCol;
  }

  return true;
}

function isValidQueenMove(board: Board, from: [number, number], to: [number, number]): boolean {
  return isValidRookMove(board, from, to) || isValidBishopMove(board, from, to);
}

function isValidKingMove(from: [number, number], to: [number, number]): boolean {
  const dRow = Math.abs(to[0] - from[0]);
  const dCol = Math.abs(to[1] - from[1]);
  return dRow <= 1 && dCol <= 1;
  // Castling would be implemented here, requires hasMoved state on pieces.
}

// --- Main Validation Function ---

export function isMoveValid(board: Board, from: [number, number], to: [number, number]): boolean {
  const [fromRow, fromCol] = from;
  const [toRow, toCol] = to;

  if (!isInsideBoard(fromRow, fromCol) || !isInsideBoard(toRow, toCol)) return false;
  if (fromRow === toRow && fromCol === toCol) return false;

  const piece = getPiece(board, fromRow, fromCol);
  if (!piece) return false;

  const targetPiece = getPiece(board, toRow, toCol);
  if (targetPiece && targetPiece.color === piece.color) return false;

  // Check piece-specific rules
  switch (piece.type) {
    case 'pawn':   return isValidPawnMove(board, from, to);
    case 'rook':   return isValidRookMove(board, from, to);
    case 'knight': return isValidKnightMove(from, to);
    case 'bishop': return isValidBishopMove(board, from, to);
    case 'queen':  return isValidQueenMove(board, from, to);
    case 'king':   return isValidKingMove(from, to);
    default:       return false;
  }
}

// Future additions: isKingInCheck, isCheckmate, isStalemate
