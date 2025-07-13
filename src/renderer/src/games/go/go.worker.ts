
// src/renderer/src/games/go/go.worker.ts

// --- Types and Logic copied from goLogic.ts for self-containment ---
type Player = 'black' | 'white';
type Board = Array<Array<Player | null>>;

function findGroup(x: number, y: number, board: Board, player: Player): { stones: {x: number, y: number}[], liberties: {x: number, y: number}[] } {
  const boardSize = board.length;
  const checked = Array(boardSize).fill(null).map(() => Array(boardSize).fill(false));
  const stones: {x: number, y: number}[] = [];
  const liberties: {x: number, y: number}[] = [];
  const q: {x: number, y: number}[] = [{x, y}];

  if (x < 0 || x >= boardSize || y < 0 || y >= boardSize || checked[y][x]) {
    return { stones: [], liberties: [] };
  }
  checked[y][x] = true;

  while (q.length > 0) {
    const stone = q.shift()!;
    stones.push(stone);

    const neighbors = [
      {x: stone.x + 1, y: stone.y},
      {x: stone.x - 1, y: stone.y},
      {x: stone.x, y: stone.y + 1},
      {x: stone.x, y: stone.y - 1},
    ];

    for (const n of neighbors) {
      if (n.x >= 0 && n.x < boardSize && n.y >= 0 && n.y < boardSize && !checked[n.y][n.x]) {
        checked[n.y][n.x] = true;
        if (board[n.y][n.x] === player) {
          q.push(n);
        } else if (board[n.y][n.x] === null) {
          liberties.push(n);
        }
      }
    }
  }

  const uniqueLiberties = liberties.filter((v, i, a) => a.findIndex(t => (t.x === v.x && t.y === v.y)) === i);
  return { stones, liberties: uniqueLiberties };
}

// --- Simple Go AI ---

function findBestMove(board: Board, player: Player): { row: number, col: number } | null {
  const boardSize = board.length;
  let bestMove: { row: number, col: number } | null = null;
  let maxScore = -Infinity;
  const possibleMoves = [];

  for (let r = 0; r < boardSize; r++) {
    for (let c = 0; c < boardSize; c++) {
      if (board[r][c] === null) {
        // Create a temporary board for evaluation
        const tempBoard = board.map(row => [...row]);
        tempBoard[r][c] = player;

        // --- Check for captures ---
        let captures = 0;
        const opponent = player === 'black' ? 'white' : 'black';
        const neighbors = [{x: c+1, y: r}, {x: c-1, y: r}, {x: c, y: r+1}, {x: c, y: r-1}];
        for (const n of neighbors) {
          if (n.x >= 0 && n.x < boardSize && n.y >= 0 && n.y < boardSize && tempBoard[n.y][n.x] === opponent) {
            const group = findGroup(n.x, n.y, tempBoard, opponent);
            if (group.liberties.length === 0) {
              captures += group.stones.length;
            }
          }
        }

        // --- Check for suicide ---
        const ownGroup = findGroup(c, r, tempBoard, player);
        if (ownGroup.liberties.length === 0 && captures === 0) {
          continue; // Illegal suicide move, skip
        }

        // --- Evaluate the move ---
        let score = 0;
        if (captures > 0) {
          score += captures * 100; // High score for captures
        }
        score += ownGroup.liberties.length; // Add score for liberties

        // Simple heuristic: prefer moves closer to the center early on
        const center = Math.floor(boardSize / 2);
        score -= Math.abs(r - center) + Math.abs(c - center);

        possibleMoves.push({ move: { row: r, col: c }, score });
      }
    }
  }

  // Find the move with the highest score
  for (const pMove of possibleMoves) {
      if (pMove.score > maxScore) {
          maxScore = pMove.score;
          bestMove = pMove.move;
      }
  }

  // If no good move is found, pick a random one from the valid moves
  if (!bestMove && possibleMoves.length > 0) {
      bestMove = possibleMoves[Math.floor(Math.random() * possibleMoves.length)].move;
  }

  return bestMove;
}

self.onmessage = (e) => {
  const { board, player } = e.data;
  const bestMove = findBestMove(board, player);
  // Add a small delay to simulate thinking and prevent UI from feeling too jerky
  setTimeout(() => {
    self.postMessage(bestMove);
  }, 500);
};
