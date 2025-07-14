
import React, { useState, useEffect, useCallback } from 'react';
import { generateSudoku, solveSudoku } from '../games/sudoku/sudokuLogic';

// --- Helper function to find all conflicting cells (no changes here) ---
const findConflictCells = (board: (number | null)[]): Set<number> => {
    const conflicts = new Set<number>();
    const addConflicts = (indices: number[]) => { if (indices.length > 1) indices.forEach(i => conflicts.add(i)); };
    for (let i = 0; i < 9; i++) {
        const seen = new Map<number, number[]>();
        board.slice(i * 9, i * 9 + 9).forEach((num, j) => {
            if (num !== null) {
                const idx = i * 9 + j;
                if (!seen.has(num)) seen.set(num, []);
                seen.get(num)!.push(idx);
            }
        });
        for (const indices of seen.values()) addConflicts(indices);
    }
    for (let i = 0; i < 9; i++) {
        const seen = new Map<number, number[]>();
        for (let j = 0; j < 9; j++) {
            const idx = j * 9 + i;
            if (board[idx] !== null) {
                if (!seen.has(board[idx]!)) seen.set(board[idx]!, []);
                seen.get(board[idx]!)!.push(idx);
            }
        }
        for (const indices of seen.values()) addConflicts(indices);
    }
    for (let box = 0; box < 9; box++) {
        const seen = new Map<number, number[]>();
        const boxRow = Math.floor(box / 3) * 3;
        const boxCol = (box % 3) * 3;
        for (let i = 0; i < 3; i++) {
            for (let j = 0; j < 3; j++) {
                const idx = (boxRow + i) * 9 + (boxCol + j);
                if (board[idx] !== null) {
                    if (!seen.has(board[idx]!)) seen.set(board[idx]!, []);
                    seen.get(board[idx]!)!.push(idx);
                }
            }
        }
        for (const indices of seen.values()) addConflicts(indices);
    }
    return conflicts;
};

const SudokuBoard: React.FC = () => {
  const [board, setBoard] = useState<(number | null)[]>([]);
  const [initialBoard, setInitialBoard] = useState<(number | null)[]>([]);
  const [selectedCell, setSelectedCell] = useState<number | null>(null);
  const [errorCells, setErrorCells] = useState<Set<number>>(new Set());
  const [isPlayerSolved, setIsPlayerSolved] = useState(false);
  const [isAiSolved, setIsAiSolved] = useState(false);
  const [boardSize, setBoardSize] = useState(0);
  const containerRef = React.useRef<HTMLDivElement>(null);

  const updateBoardSize = useCallback(() => {
    if (containerRef.current) {
        const { width, height } = containerRef.current.parentElement!.getBoundingClientRect();
        const size = Math.min(width, height) * 0.85; // Use 85% of the smallest dimension of the parent
        setBoardSize(Math.min(size, 700)); // With a max size of 700px
    }
  }, []);

  useEffect(() => {
    window.addEventListener('resize', updateBoardSize);
    updateBoardSize();
    return () => window.removeEventListener('resize', updateBoardSize);
  }, [updateBoardSize]);

  const startNewGame = useCallback(() => {
    const newBoard = generateSudoku();
    setBoard(newBoard);
    setInitialBoard(JSON.parse(JSON.stringify(newBoard)));
    setSelectedCell(null);
    setIsPlayerSolved(false);
    setIsAiSolved(false);
    updateBoardSize();
  }, [updateBoardSize]);

  useEffect(() => { startNewGame(); }, [startNewGame]);

  useEffect(() => {
    const conflicts = findConflictCells(board);
    setErrorCells(conflicts);
    const isBoardFull = !board.includes(null);
    if (isBoardFull && conflicts.size === 0 && !isAiSolved) {
      setIsPlayerSolved(true);
    }
  }, [board, isAiSolved]);

  const handleSolve = () => {
    const solvedBoard = [...initialBoard];
    if (solveSudoku(solvedBoard)) {
      setBoard(solvedBoard);
      setIsAiSolved(true);
      setSelectedCell(null);
    }
  };

  const handleReset = () => {
    setBoard(JSON.parse(JSON.stringify(initialBoard)));
    setIsAiSolved(false);
    setIsPlayerSolved(false);
  };

  const handleCellChange = (index: number, value: string) => {
    const newBoard = [...board];
    if (/^[1-9]$/.test(value) || value === '') {
      const num = value === '' ? null : parseInt(value, 10);
      newBoard[index] = num;
      setBoard(newBoard);
    }
  };

  const getCellContainerStyle = (index: number): React.CSSProperties => {
    const style: React.CSSProperties = { display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'background-color 0.15s ease-in-out' };
    const row = Math.floor(index / 9), col = index % 9;
    const isInitial = initialBoard[index] !== null;
    let isHighlighted = false;

    if (selectedCell !== null && !isAiSolved) {
      const selectedRow = Math.floor(selectedCell / 9), selectedCol = selectedCell % 9;
      if (row === selectedRow || col === selectedCol || (Math.floor(row / 3) === Math.floor(selectedRow / 3) && Math.floor(col / 3) === Math.floor(selectedCol / 3))) isHighlighted = true;
    }

    if (index === selectedCell && !isAiSolved) style.backgroundColor = '#bae6fd';
    else if (isHighlighted) style.backgroundColor = isInitial ? '#d6d3d1' : '#f0f9ff';
    else style.backgroundColor = isInitial ? '#e7e5e4' : '#ffffff';
    if (isAiSolved) style.backgroundColor = isInitial ? '#e7e5e4' : '#f8fafc';

    style.borderRight = col % 3 === 2 ? '2px solid #475569' : '1px solid #d1d5db';
    style.borderBottom = row % 3 === 2 ? '2px solid #475569' : '1px solid #d1d5db';
    if (row === 0) style.borderTop = '2px solid #475569';
    if (col === 0) style.borderLeft = '2px solid #475569';

    return style;
  };

  const getNumberStyle = (): React.CSSProperties => ({ fontSize: boardSize / 22, fontFamily: 'sans-serif', userSelect: 'none' });

  return (
    <div ref={containerRef} style={{ position: 'relative', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '1rem', backgroundColor: '#f5f5f4', borderRadius: '8px', boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)' }}>
      {isPlayerSolved && (
        <div style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0, 0, 0, 0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 10, borderRadius: '8px' }}>
          <div style={{ backgroundColor: 'white', padding: '2rem', borderRadius: '1rem', textAlign: 'center', boxShadow: '0 20px 25px -5px rgba(0,0,0,0.1)' }}>
            <h2 style={{ fontSize: boardSize / 18, color: '#16a34a', marginBottom: '1rem' }}>恭喜通关！</h2>
            <p style={{ fontSize: boardSize / 25, color: '#4b5563', marginBottom: '1.5rem' }}>你太棒了！准备好迎接新的挑战了吗？</p>
            <button onClick={startNewGame} style={{ padding: '0.75rem 1.5rem', fontSize: boardSize / 28, color: 'white', backgroundColor: '#2563eb', borderRadius: '0.5rem', border: 'none', cursor: 'pointer', fontWeight: 'bold' }}>
              开始下一关
            </button>
          </div>
        </div>
      )}
      
      <div style={{ width: boardSize, height: boardSize, display: 'grid', gridTemplateColumns: 'repeat(9, 1fr)', boxShadow: '0 4px 12px rgba(0,0,0,0.2)' }}>
        {board.map((cell, index) => {
          const isInitial = initialBoard[index] !== null;
          const numberStyle = getNumberStyle();
          if (errorCells.has(index) && !isAiSolved) numberStyle.color = '#ef4444';
          else if (isInitial) numberStyle.color = '#1e293b';
          else numberStyle.color = isAiSolved ? '#64748b' : '#0369a1';

          return (
            <div key={index} style={getCellContainerStyle(index)} onClick={() => !isInitial && !isAiSolved && setSelectedCell(index)}>
              {isInitial ? (
                <span style={numberStyle}>{cell}</span>
              ) : (
                <input
                  type="text" pattern="[1-9]*" inputMode="numeric" maxLength={1}
                  value={cell === null ? '' : cell}
                  onChange={(e) => handleCellChange(index, e.target.value)}
                  onFocus={() => setSelectedCell(index)}
                  disabled={isAiSolved}
                  style={{ ...numberStyle, width: '100%', height: '100%', backgroundColor: 'transparent', textAlign: 'center', border: 'none', outline: 'none', padding: 0, cursor: isAiSolved ? 'not-allowed' : 'text' }}
                />
              )}
            </div>
          );
        })}
      </div>

      <div style={{ display: 'flex', gap: boardSize / 25, marginTop: boardSize / 20 }}>
        {['New Game', 'Reset', 'Solve'].map(label => {
            const isDisabled = isAiSolved && (label === 'Reset' || label === 'Solve');
            return (
                <button 
                    key={label} 
                    onClick={label === 'New Game' ? startNewGame : label === 'Reset' ? handleReset : handleSolve}
                    disabled={isDisabled}
                    style={{
                        padding: `${boardSize / 40}px ${boardSize / 20}px`,
                        fontSize: boardSize / 28,
                        color: 'white',
                        backgroundColor: isDisabled ? '#a1a1aa' : (label === 'New Game' ? '#16a34a' : label === 'Reset' ? '#f59e0b' : '#0284c7'),
                        borderRadius: '0.5rem',
                        border: 'none',
                        cursor: isDisabled ? 'not-allowed' : 'pointer'
                    }}
                >
                    {label}
                </button>
            );
        })}
      </div>
    </div>
  );
};

export default SudokuBoard;
