
export type Player = 'black' | 'white';
export type Board = Array<Array<Player | null>>;

export function checkWin(board: Board, row: number, col: number, player: Player): boolean {
  const boardSize = board.length;

  // Check horizontal
  let count = 0;
  for (let i = 0; i < boardSize; i++) {
    count = board[row][i] === player ? count + 1 : 0;
    if (count >= 5) return true;
  }

  // Check vertical
  count = 0;
  for (let i = 0; i < boardSize; i++) {
    count = board[i][col] === player ? count + 1 : 0;
    if (count >= 5) return true;
  }

  // Check diagonal (top-left to bottom-right)
  count = 0;
  for (let i = -4; i <= 4; i++) {
    const r = row + i;
    const c = col + i;
    if (r >= 0 && r < boardSize && c >= 0 && c < boardSize) {
      count = board[r][c] === player ? count + 1 : 0;
      if (count >= 5) return true;
    }
  }

  // Check anti-diagonal (top-right to bottom-left)
  count = 0;
  for (let i = -4; i <= 4; i++) {
    const r = row + i;
    const c = col - i;
    if (r >= 0 && r < boardSize && c >= 0 && c < boardSize) {
      count = board[r][c] === player ? count + 1 : 0;
      if (count >= 5) return true;
    }
  }

  return false;
}
