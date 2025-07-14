
export const generateSudoku = (): (number | null)[] => {
  const board = Array(81).fill(null);
  solveSudoku(board);
  removeNumbers(board, 40);
  return board;
};

export const solveSudoku = (board: (number | null)[]): boolean => {
  const find = findEmpty(board);
  if (!find) {
    return true;
  } else {
    const [row, col] = find;
    for (let i = 1; i <= 9; i++) {
      if (isValid(board, i, [row, col])) {
        board[row * 9 + col] = i;
        if (solveSudoku(board)) {
          return true;
        }
        board[row * 9 + col] = null;
      }
    }
  }
  return false;
};

const removeNumbers = (board: (number | null)[], count: number) => {
  let removed = 0;
  while (removed < count) {
    const index = Math.floor(Math.random() * 81);
    if (board[index] !== null) {
      board[index] = null;
      removed++;
    }
  }
};

const findEmpty = (board: (number | null)[]): [number, number] | null => {
  for (let i = 0; i < 9; i++) {
    for (let j = 0; j < 9; j++) {
      if (board[i * 9 + j] === null) {
        return [i, j];
      }
    }
  }
  return null;
};

const isValid = (board: (number | null)[], num: number, pos: [number, number]): boolean => {
  const [row, col] = pos;

  for (let i = 0; i < 9; i++) {
    if (board[row * 9 + i] === num && col !== i) {
      return false;
    }
  }

  for (let i = 0; i < 9; i++) {
    if (board[i * 9 + col] === num && row !== i) {
      return false;
    }
  }

  const boxX = Math.floor(col / 3);
  const boxY = Math.floor(row / 3);

  for (let i = boxY * 3; i < boxY * 3 + 3; i++) {
    for (let j = boxX * 3; j < boxX * 3 + 3; j++) {
      if (board[i * 9 + j] === num && (i !== row || j !== col)) {
        return false;
      }
    }
  }

  return true;
};
