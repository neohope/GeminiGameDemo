
import { findBestMove } from './chineseChessAI';

self.onmessage = (e) => {
  const { board, player } = e.data;
  const bestMove = findBestMove(board, player);
  self.postMessage(bestMove);
};
