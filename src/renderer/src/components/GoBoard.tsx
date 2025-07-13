import React, { useState, useEffect, useRef } from 'react';
import { findGroup, calculateScore, Player, Board } from '../games/go/goLogic';
import '../types'; // Ensure global types are loaded

const boardSize = 19;

type GameState = {
  board: Board;
  currentPlayer: Player;
  capturedByBlack: number;
  capturedByWhite: number;
  lastMoveWasPass: boolean;
}

const initialGameState: GameState = {
  board: Array(boardSize).fill(null).map(() => Array(boardSize).fill(null)),
  currentPlayer: 'black',
  capturedByBlack: 0,
  capturedByWhite: 0,
  lastMoveWasPass: false,
};

const GoBoard: React.FC = () => {
  const [history, setHistory] = useState<GameState[]>([initialGameState]);
  const [isGameOver, setIsGameOver] = useState(false);
  const [finalScore, setFinalScore] = useState<{ black: number, white: number } | null>(null);
  const [gameMode, setGameMode] = useState<'hvh' | 'hva'>('hvh');
  const workerRef = useRef<Worker | null>(null);
  const boardContainerRef = useRef<HTMLDivElement>(null);
  const [gridSize, setGridSize] = useState(0);

  const currentGameState = history[history.length - 1];
  const { board, currentPlayer, capturedByBlack, capturedByWhite, lastMoveWasPass } = currentGameState;

  const starPoints = [
    { x: 3, y: 3 }, { x: 9, y: 3 }, { x: 15, y: 3 },
    { x: 3, y: 9 }, { x: 9, y: 9 }, { x: 15, y: 9 },
    { x: 3, y: 15 }, { x: 9, y: 15 }, { x: 15, y: 15 },
  ];

  // Effect to setup the AI worker
  useEffect(() => {
    workerRef.current = new Worker(new URL('../games/go/go.worker.ts', import.meta.url), { type: 'module' });

    workerRef.current.onmessage = (e) => {
      const bestMove = e.data;
      if (bestMove) {
        handlePlay(bestMove.row, bestMove.col);
      }
    };

    return () => {
      workerRef.current?.terminate();
    };
  }, []);

  // Effect to trigger AI move
  useEffect(() => {
    if (gameMode === 'hva' && currentPlayer === 'white' && !isGameOver) {
      workerRef.current?.postMessage({ board, player: 'white' });
    }
  }, [history, gameMode, isGameOver]);

  useEffect(() => {
    const calculateGridSize = () => {
      if (boardContainerRef.current) {
        const { clientWidth, clientHeight } = boardContainerRef.current;
        const newGridSize = Math.floor(Math.min(clientWidth, clientHeight) / boardSize);
        setGridSize(newGridSize);
      }
    };

    calculateGridSize();
    window.addEventListener('resize', calculateGridSize);

    return () => {
      window.removeEventListener('resize', calculateGridSize);
    };
  }, []);

  const handlePlay = (row: number, col: number) => {
    // Use functional updates to ensure we're always working with the latest state.
    setHistory(prevHistory => {
      const currentGameState = prevHistory[prevHistory.length - 1];
      const { board, currentPlayer, capturedByBlack, capturedByWhite } = currentGameState;

      if (isGameOver || board[row][col] || (gameMode === 'hva' && currentPlayer === 'white')) {
        return prevHistory; // Return previous history without change
      }

      const newBoard = board.map(r => [...r]);
      newBoard[row][col] = currentPlayer;

      let capturedStones = 0;
      const opponent = currentPlayer === 'black' ? 'white' : 'black';
      const neighbors = [{x: col + 1, y: row}, {x: col - 1, y: row}, {x: col, y: row + 1}, {x: col, y: row - 1}];

      for (const n of neighbors) {
        if (n.x >= 0 && n.x < boardSize && n.y >= 0 && n.y < boardSize && newBoard[n.y][n.x] === opponent) {
          const group = findGroup(n.x, n.y, newBoard, opponent);
          if (group.liberties.length === 0) {
            capturedStones += group.stones.length;
            for (const stone of group.stones) {
              newBoard[stone.y][stone.x] = null;
            }
          }
        }
      }

      const ownGroup = findGroup(col, row, newBoard, currentPlayer);
      if (ownGroup.liberties.length === 0 && capturedStones === 0) {
        console.log("Suicide move is not allowed!");
        return prevHistory; // Revert to previous state
      }

      const nextState: GameState = {
        board: newBoard,
        currentPlayer: opponent,
        capturedByBlack: currentPlayer === 'black' ? capturedByBlack + capturedStones : capturedByBlack,
        capturedByWhite: currentPlayer === 'white' ? capturedByWhite + capturedStones : capturedByWhite,
        lastMoveWasPass: false,
      };

      return [...prevHistory, nextState];
    });
  };

  const handlePass = () => {
    if (isGameOver) return;
    if (lastMoveWasPass) {
      endGame();
    } else {
      const nextState: GameState = { ...currentGameState, currentPlayer: currentPlayer === 'black' ? 'white' : 'black', lastMoveWasPass: true };
      setHistory([...history, nextState]);
    }
  };

  const endGame = () => {
    setIsGameOver(true);
    const { blackScore, whiteScore } = calculateScore(board);
    setFinalScore({ black: blackScore + capturedByBlack, white: whiteScore + capturedByWhite + 6.5 });
  };

  const handleUndo = () => {
    if (history.length > 1 && !isGameOver) {
      const stepsToUndo = (gameMode === 'hva' && currentPlayer === 'black' && history.length > 2) ? 2 : 1;
      setHistory(history.slice(0, history.length - stepsToUndo));
      setIsGameOver(false);
      setFinalScore(null);
    }
  };

  const handleSave = () => window.electronAPI.saveGame(currentGameState);

  const handleLoad = async () => {
    const loadedState = await window.electronAPI.loadGame() as GameState;
    if (loadedState && loadedState.board && loadedState.currentPlayer) {
      setHistory([loadedState]);
      setIsGameOver(false);
      setFinalScore(null);
    }
  };

  const resetGame = () => {
    setHistory([initialGameState]);
    setIsGameOver(false);
    setFinalScore(null);
  };

  const boardPixelSize = boardSize * gridSize;

  if (gridSize === 0) {
    return <div ref={boardContainerRef} style={{ width: '100%', height: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>Loading Board...</div>;
  }

  return (
    <div ref={boardContainerRef} style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{textAlign: 'center', marginBottom: '10px', fontSize: '18px'}}>
        <span>Black Captured: {capturedByWhite}</span>
        <span style={{marginLeft: '20px'}}>White Captured: {capturedByBlack}</span>
      </div>
      <svg width={boardPixelSize} height={boardPixelSize} style={{ border: '2px solid black', backgroundColor: '#dcb35c' }} 
        onClick={(e) => {
          const rect = e.currentTarget.getBoundingClientRect();
          const x = e.clientX - rect.left - gridSize / 2;
          const y = e.clientY - rect.top - gridSize / 2;
          handlePlay(Math.round(y / gridSize), Math.round(x / gridSize));
        }}
      >
        <g transform={`translate(${gridSize / 2}, ${gridSize / 2})`}>
          {/* ... grid and stone rendering ... */}
          {Array.from({ length: boardSize }).map((_, i) => (
            <g key={i}>
              <line x1={0} y1={i * gridSize} x2={(boardSize - 1) * gridSize} y2={i * gridSize} stroke="black" />
              <line x1={i * gridSize} y1={0} x2={i * gridSize} y2={(boardSize - 1) * gridSize} stroke="black" />
            </g>
          ))}
          {starPoints.map((p, i) => (
            <circle key={i} cx={p.x * gridSize} cy={p.y * gridSize} r={4 * gridSize / 30} fill="black" />
          ))}
          {board.map((row, r) => 
            row.map((cell, c) => 
              cell && <circle key={`${r}-${c}`} cx={c * gridSize} cy={r * gridSize} r={gridSize / 2 - 1} fill={cell} stroke="gray" strokeWidth="1" />
            )
          )
        }
        </g>
      </svg>
      {isGameOver ? (
      <div style={{fontWeight: 'bold', fontSize: '20px', marginTop: '10px'}}>
        <div>Game Over</div>
          {finalScore && <div>Black: {finalScore.black.toFixed(1)} | White: {finalScore.white.toFixed(1)}</div>}
      </div>
      ) : (
      <div style={{fontWeight: 'bold', marginTop: '10px'}}>Current Player: {currentPlayer.toUpperCase()}</div>
      )}
      <div style={{textAlign: 'center', marginTop: '10px'}}>
        <select onChange={(e) => setGameMode(e.target.value as 'hvh' | 'hva')} value={gameMode} disabled={history.length > 1} style={{ marginRight: '10px' }}>
          <option value="hvh">Human vs. Human</option>
          <option value="hva">Human vs. AI</option>
        </select>
        <button onClick={handlePass} disabled={isGameOver}>Pass</button>
        <button onClick={handleUndo} disabled={history.length <= 1 || isGameOver}>Undo</button>
        <button onClick={handleSave} disabled={isGameOver}>Save</button>
        <button onClick={handleLoad} disabled={isGameOver}>Load</button>
        <button onClick={resetGame}>Reset Game</button>
      </div>
    </div>
  );
};

export default GoBoard;
