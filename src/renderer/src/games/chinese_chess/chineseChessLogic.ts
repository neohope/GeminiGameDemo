
export type Player = 'red' | 'black';
export type Piece = {
  id: number;
  x: number;
  y: number;
  text: string;
  color: Player;
};
export type Board = Piece[];

function getPieceAt(x: number, y: number, board: Board): Piece | null {
  return board.find(p => p.x === x && p.y === y) || null;
}

export function isValidMove(piece: Piece, toX: number, toY: number, board: Board, showLog: boolean): boolean {
  if(showLog) console.log(`Checking move for ${piece.text} from (${piece.x},${piece.y}) to (${toX},${toY})`);
  const targetPiece = getPieceAt(toX, toY, board);

  if (targetPiece && targetPiece.color === piece.color) {
    if(showLog) console.log(`Invalid move: Target square (${toX},${toY}) occupied by own piece.`);
    return false;
  }

  const dx = Math.abs(piece.x - toX);
  const dy = Math.abs(piece.y - toY);

  switch (piece.text) {
    case '車': // Chariot
      if (piece.x !== toX && piece.y !== toY) {
        if(showLog) console.log(`Invalid move for Chariot: Not moving in a straight line.`);
        return false;
      }
      if (piece.x === toX) {
        const start = Math.min(piece.y, toY); const end = Math.max(piece.y, toY);
        for (let y = start + 1; y < end; y++) {
          if (getPieceAt(toX, y, board)) {
            if(showLog) console.log(`Invalid move for Chariot: Path blocked at (${toX},${y}).`);
            return false;
          }
        }
      } else {
        const start = Math.min(piece.x, toX); const end = Math.max(piece.x, toX);
        for (let x = start + 1; x < end; x++) {
          if (getPieceAt(x, toY, board)) {
            if(showLog) console.log(`Invalid move for Chariot: Path blocked at (${x},${toY}).`);
            return false;
          }
        }
      }
      if(showLog) console.log(`Valid move for Chariot.`);
      return true;

    case '馬': // Horse
      if (!((dx === 1 && dy === 2) || (dx === 2 && dy === 1))) {
        if(showLog) console.log(`Invalid move for Horse: Not a valid L-shape.`);
        return false;
      }
      if (dx === 1) { // Vertical 'L'
        if (getPieceAt(piece.x, piece.y + (toY > piece.y ? 1 : -1), board)) {
          if(showLog) console.log(`Invalid move for Horse: Blocked at (${piece.x},${piece.y + (toY > piece.y ? 1 : -1)}).`);
          return false;
        }
      } else { // Horizontal 'L'
        if (getPieceAt(piece.x + (toX > piece.x ? 1 : -1), piece.y, board)) {
          if(showLog) console.log(`Invalid move for Horse: Blocked at (${piece.x + (toX > piece.x ? 1 : -1)},${piece.y}).`);
          return false;
        }
      }
      if(showLog) console.log(`Valid move for Horse.`);
      return true;

    case '相': // Elephant (Red)
    case '象': // Elephant (Black)
      if (dx !== 2 || dy !== 2) {
        if(showLog) console.log(`Invalid move for Elephant: Not moving two steps diagonally.`);
        return false;
      }
      if (piece.color === 'red' && toY > 4) {
        if(showLog) console.log(`Invalid move for Red Elephant: Cannot cross river.`);
        return false; // Cannot cross river
      }
      if (piece.color === 'black' && toY < 5) {
        console.log(`Invalid move for Black Elephant: Cannot cross river.`);
        if(showLog) return false; // Cannot cross river
      }
      if (getPieceAt(piece.x + (toX > piece.x ? 1 : -1), piece.y + (toY > piece.y ? 1 : -1), board)) {
        if(showLog) console.log(`Invalid move for Elephant: Eye is blocked.`);
        return false; // Eye is blocked
      }
      if(showLog) console.log(`Valid move for Elephant.`);
      return true;

    case '仕': // Guard (Red)
    case '士': // Guard (Black)
      if (dx !== 1 || dy !== 1) {
        if(showLog) console.log(`Invalid move for Guard: Not moving one step diagonally.`);
        return false;
      }
      if (toX < 3 || toX > 5) {
        if(showLog) console.log(`Invalid move for Guard: Outside palace horizontally.`);
        return false; // Must stay in palace
      }
      if (piece.color === 'red' && toY > 2) {
        if(showLog) console.log(`Invalid move for Red Guard: Outside palace vertically.`);
        return false;
      }
      if (piece.color === 'black' && toY < 7) {
        if(showLog) console.log(`Invalid move for Black Guard: Outside palace vertically.`);
        return false;
      }
      if(showLog) console.log(`Valid move for Guard.`);
      return true;

    case '帥': // General (Red)
    case '將': // General (Black)
      if (dx > 1 || dy > 1 || (dx === 0 && dy === 0)) {
        if(showLog) console.log(`Invalid move for General: Not moving one step or no movement.`);
        return false;
      }
      if (toX < 3 || toX > 5) {
        if(showLog) console.log(`Invalid move for General: Outside palace horizontally.`);
        return false; // Must stay in palace
      }
      if (piece.color === 'red' && toY > 2) {
        if(showLog) console.log(`Invalid move for Red General: Outside palace vertically.`);
        return false;
      }
      if (piece.color === 'black' && toY < 7) {
        if(showLog) console.log(`Invalid move for Black General: Outside palace vertically.`);
        return false;
      }
      if(showLog) console.log(`Valid move for General.`);
      return true;

    case '炮': // Cannon (Red)
    case '砲': // Cannon (Black)
      if (piece.x !== toX && piece.y !== toY) {
        if(showLog) console.log(`Invalid move for Cannon: Not moving in a straight line.`);
        return false;
      }
      let pathPieces = 0;
      if (piece.x === toX) {
        const start = Math.min(piece.y, toY); const end = Math.max(piece.y, toY);
        for (let y = start + 1; y < end; y++) if (getPieceAt(toX, y, board)) pathPieces++;
      } else {
        const start = Math.min(piece.x, toX); const end = Math.max(piece.x, toX);
        for (let x = start + 1; x < end; x++) if (getPieceAt(x, toY, board)) pathPieces++;
      }
      if (targetPiece && pathPieces === 1) {
        if(showLog) console.log(`Valid capture for Cannon: One piece in between.`);
        return true; // Capture
      }
      if (!targetPiece && pathPieces === 0) {
        if(showLog) console.log(`Valid move for Cannon: No pieces in between.`);
        return true; // Move
      }
      if(showLog) console.log(`Invalid move for Cannon: Incorrect number of pieces in between for move or capture.`);
      return false;

    case '兵': // Pawn (Red)
      if (dy > 1 || dx > 1 || (dx === 1 && dy === 1)) {
        if(showLog) console.log(`Invalid move for Red Pawn: Not moving one step or diagonally.`);
        return false;
      }
      if (piece.y < 5 && toY < piece.y) {
        if(showLog) console.log(`Invalid move for Red Pawn: Cannot move backward before river.`);
        return false; // Cannot move backward before river
      }
      if (toY === piece.y && dx !== 0) {
        if(showLog) console.log(`Invalid move for Red Pawn: Cannot move sideways before river.`);
        return false; // Cannot move sideways before river
      }
      if(showLog) console.log(`Valid move for Red Pawn.`);
      return true;

    case '卒': // Pawn (Black)
      if (dy > 1 || dx > 1 || (dx === 1 && dy === 1)) {
        if(showLog) console.log(`Invalid move for Black Pawn: Not moving one step or diagonally.`);
        return false;
      }
      if (piece.y > 4 && toY > piece.y) {
        if(showLog) console.log(`Invalid move for Black Pawn: Cannot move backward before river.`);
        return false; // Cannot move backward before river
      }
      if (toY === piece.y && dx !== 0) {
        if(showLog) console.log(`Invalid move for Black Pawn: Cannot move sideways before river.`);
        return false; // Cannot move sideways before river
      }
      if(showLog) console.log(`Valid move for Black Pawn.`);
      return true;

    default:
      return false;
  }
}

export function isKingInCheck(player: Player, board: Board): boolean {
  const king = board.find(p => p.color === player && (p.text === '帥' || p.text === '將'));
  if (!king) return false; // Should not happen

  const opponent = player === 'red' ? 'black' : 'red';
  const opponentPieces = board.filter(p => p.color === opponent);

  for (const piece of opponentPieces) {
    if (isValidMove(piece, king.x, king.y, board, false)) {
      return true;
    }
  }

  // Flying General rule
  const opponentKing = board.find(p => p.color === opponent && (p.text === '帥' || p.text === '將'));
  if (opponentKing && king.x === opponentKing.x) {
    const start = Math.min(king.y, opponentKing.y);
    const end = Math.max(king.y, opponentKing.y);
    let piecesInBetween = 0;
    for (let y = start + 1; y < end; y++) {
      if (getPieceAt(king.x, y, board)) {
        piecesInBetween++;
      }
    }
    if (piecesInBetween === 0) {
      return true;
    }
  }

  return false;
}

export function isGameOver(player: Player, board: Board): 'checkmate' | 'stalemate' | null {
  // Check if the player has any legal moves
  const playerPieces = board.filter(p => p.color === player);
  for (const piece of playerPieces) {
    for (let y = 0; y < 10; y++) {
      for (let x = 0; x < 9; x++) {
        if (isValidMove(piece, x, y, board, false)) {
          // Simulate the move
          const tempBoard = board
            .filter(p => !(p.x === x && p.y === y))
            .map(p => p.id === piece.id ? { ...p, x, y } : p);
          // If the move does not result in the king being in check, it's a legal move
          if (!isKingInCheck(player, tempBoard)) {
            return null; // Game is not over, legal move found
          }
        }
      }
    }
  }

  // If no legal moves are found, determine if it's checkmate or stalemate
  if (isKingInCheck(player, board)) {
    return 'checkmate';
  } else {
    return 'stalemate';
  }
}
