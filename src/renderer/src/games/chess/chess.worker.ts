// chess.worker.ts

// --- Types (copied from chessLogic.ts for self-containment) ---
type Player = 'white' | 'black';
type PieceType = 'pawn' | 'rook' | 'knight' | 'bishop' | 'queen' | 'king';
type Piece = { type: PieceType; color: Player; hasMoved?: boolean };
type Board = (Piece | null)[][];
type Move = { from: [number, number]; to: [number, number] };

const boardSize = 8;

// --- Core Logic (copied from chessLogic.ts) ---

function isInsideBoard(row: number, col: number): boolean {
  return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
}

function getPiece(board: Board, row: number, col: number): Piece | null {
  if (!isInsideBoard(row, col)) return null;
  return board[row][col];
}

function isValidPawnMove(board: Board, from: [number, number], to: [number, number]): boolean {
  const [fromRow, fromCol] = from;
  const [toRow, toCol] = to;
  const piece = getPiece(board, fromRow, fromCol);
  if (!piece) return false;

  const direction = piece.color === 'white' ? -1 : 1;
  const startRow = piece.color === 'white' ? 6 : 1;

  if (fromCol === toCol && !getPiece(board, toRow, toCol) && toRow === fromRow + direction) return true;
  if (fromCol === toCol && !getPiece(board, toRow, toCol) && fromRow === startRow && toRow === fromRow + 2 * direction && !getPiece(board, fromRow + direction, fromCol)) return true;
  if (Math.abs(fromCol - toCol) === 1 && toRow === fromRow + direction) {
    const targetPiece = getPiece(board, toRow, toCol);
    return targetPiece !== null && targetPiece.color !== piece.color;
  }
  return false;
}

function isValidRookMove(board: Board, from: [number, number], to: [number, number]): boolean {
  const [fromRow, fromCol] = from;
  const [toRow, toCol] = to;
  if (fromRow !== toRow && fromCol !== toCol) return false;
  const stepRow = fromRow === toRow ? 0 : (toRow > fromRow ? 1 : -1);
  const stepCol = fromCol === toCol ? 0 : (toCol > fromCol ? 1 : -1);
  let currentRow = fromRow + stepRow;
  let currentCol = fromCol + stepCol;
  while (currentRow !== toRow || currentCol !== toCol) {
    if (getPiece(board, currentRow, currentCol)) return false;
    currentRow += stepRow;
    currentCol += stepCol;
  }
  return true;
}

function isValidKnightMove(from: [number, number], to: [number, number]): boolean {
  const dRow = Math.abs(to[0] - from[0]);
  const dCol = Math.abs(to[1] - from[1]);
  return (dRow === 2 && dCol === 1) || (dRow === 1 && dCol === 2);
}

function isValidBishopMove(board: Board, from: [number, number], to: [number, number]): boolean {
  const [fromRow, fromCol] = from;
  const [toRow, toCol] = to;
  if (Math.abs(toRow - fromRow) !== Math.abs(toCol - fromCol)) return false;
  const stepRow = toRow > fromRow ? 1 : -1;
  const stepCol = toCol > fromCol ? 1 : -1;
  let currentRow = fromRow + stepRow;
  let currentCol = fromCol + stepCol;
  while (currentRow !== toRow || currentCol !== toCol) {
    if (getPiece(board, currentRow, currentCol)) return false;
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
}

function isMoveValid(board: Board, from: [number, number], to: [number, number]): boolean {
  const [fromRow, fromCol] = from;
  const [toRow, toCol] = to;
  if (!isInsideBoard(fromRow, fromCol) || !isInsideBoard(toRow, toCol)) return false;
  if (fromRow === toRow && fromCol === toCol) return false;
  const piece = getPiece(board, fromRow, fromCol);
  if (!piece) return false;
  const targetPiece = getPiece(board, toRow, toCol);
  if (targetPiece && targetPiece.color === piece.color) return false;

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

// --- New AI Logic ---

function findBestMove(board: Board, player: Player): Move | null {
  const possibleMoves: Move[] = [];

  // Iterate over all squares to find pieces belonging to the AI player
  for (let r = 0; r < boardSize; r++) {
    for (let c = 0; c < boardSize; c++) {
      const piece = board[r][c];
      if (piece && piece.color === player) {
        // For each piece, iterate over all possible destination squares
        for (let tr = 0; tr < boardSize; tr++) {
          for (let tc = 0; tc < boardSize; tc++) {
            const from: [number, number] = [r, c];
            const to: [number, number] = [tr, tc];
            // Check if the move is valid according to the game rules
            if (isMoveValid(board, from, to)) {
              possibleMoves.push({ from, to });
            }
          }
        }
      }
    }
  }

  // If there are any valid moves, return a random one.
  if (possibleMoves.length > 0) {
    return possibleMoves[Math.floor(Math.random() * possibleMoves.length)];
  }

  // If no moves are possible (checkmate or stalemate), return null.
  return null;
}

// --- Worker Message Handler ---

self.onmessage = (e) => {
  const { board, player } = e.data;
  // The depth parameter is no longer needed for this simple random-move AI.
  const bestMove = findBestMove(board, player);
  self.postMessage(bestMove);
};