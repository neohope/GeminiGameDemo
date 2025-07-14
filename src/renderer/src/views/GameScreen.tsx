import React from 'react';
import SudokuBoard from '../components/SudokuBoard';
import GomokuBoard from '../components/GomokuBoard';
import ChineseChessBoard from '../components/ChineseChessBoard';
import GoBoard from '../components/GoBoard';
import ChessBoard from '../components/ChessBoard';

type Props = {
  game: string;
  onBack: () => void;
};

const GameScreen: React.FC<Props> = ({ game, onBack }) => {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100vh' }}>
      <div style={{ padding: '10px', textAlign: 'left' }}>
        <button onClick={onBack}>← Back to Menu</button>
      </div>
      <div style={{ flexGrow: 1, display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
        {game === 'gomoku' && <GomokuBoard />}
        {game === 'chinese_chess' && <ChineseChessBoard />}
        {game === 'go' && <GoBoard />}
        {game === 'chess' && <ChessBoard />}
        {game === 'sudoku' && <SudokuBoard />}
      </div>
    </div>
  );
};

export default GameScreen;
