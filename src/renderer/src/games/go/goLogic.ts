
export type Player = 'black' | 'white';
export type Board = Array<Array<Player | null>>;

// Finds all stones in a connected group starting from (x, y)
export function findGroup(x: number, y: number, board: Board, player: Player): { stones: {x: number, y: number}[], liberties: {x: number, y: number}[] } {
  const boardSize = board.length;
  const checked = Array(boardSize).fill(null).map(() => Array(boardSize).fill(false));
  const stones: {x: number, y: number}[] = [];
  const liberties: {x: number, y: number}[] = [];
  const q: {x: number, y: number}[] = [{x, y}];

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

  // Remove duplicate liberties
  const uniqueLiberties = liberties.filter((v, i, a) => a.findIndex(t => (t.x === v.x && t.y === v.y)) === i);

  return { stones, liberties: uniqueLiberties };
}

export function calculateScore(board: Board): { blackScore: number, whiteScore: number } {
  const boardSize = board.length;
  let blackScore = 0;
  let whiteScore = 0;
  const checked = Array(boardSize).fill(null).map(() => Array(boardSize).fill(false));

  for (let y = 0; y < boardSize; y++) {
    for (let x = 0; x < boardSize; x++) {
      if (board[y][x] === null && !checked[y][x]) {
        const q = [{x, y}];
        const territory = [{x, y}];
        let owner: Player | null = null;
        let isBorderedByBlack = false;
        let isBorderedByWhite = false;
        checked[y][x] = true;

        while(q.length > 0) {
          const current = q.shift()!;
          const neighbors = [{x: current.x + 1, y: current.y}, {x: current.x - 1, y: current.y}, {x: current.x, y: current.y + 1}, {x: current.x, y: current.y - 1}];

          for (const n of neighbors) {
            if (n.x >= 0 && n.x < boardSize && n.y >= 0 && n.y < boardSize) {
              if (board[n.y][n.x] === null && !checked[n.y][n.x]) {
                checked[n.y][n.x] = true;
                q.push(n);
                territory.push(n);
              } else if (board[n.y][n.x] === 'black') {
                isBorderedByBlack = true;
              } else if (board[n.y][n.x] === 'white') {
                isBorderedByWhite = true;
              }
            }
          }
        }

        if (isBorderedByBlack && !isBorderedByWhite) {
          blackScore += territory.length;
        } else if (!isBorderedByBlack && isBorderedByWhite) {
          whiteScore += territory.length;
        }
      }
    }
  }

  return { blackScore, whiteScore };
}
