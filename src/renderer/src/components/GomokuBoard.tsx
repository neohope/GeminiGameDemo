import React, { useState, useEffect, useRef } from 'react';
import { checkWin, Player } from '../games/gomoku/gomokuLogic';
import '../types'; // Import for global type declarations

// --- Types and Constants ---
type Board = (Player | null)[][];
type GameState = { board: Board; currentPlayer: Player; };
type GameMode = 'hvh' | 'hva';

const boardSize = 15; // This remains constant for Gomoku

const initialGameState: GameState = {
  board: Array(boardSize).fill(null).map(() => Array(boardSize).fill(null)),
  currentPlayer: 'black',
};

// --- React Component ---
const GomokuBoard = () => {
  const [history, setHistory] = useState<GameState[]>([initialGameState]);
  const [winner, setWinner] = useState<Player | null>(null);
  const [gameMode, setGameMode] = useState<GameMode>('hvh');
  const workerRef = useRef<Worker | null>(null);
  const boardContainerRef = useRef<HTMLDivElement>(null);
  const boardWrapperRef = useRef<HTMLDivElement>(null); // New ref
  const [gridSize, setGridSize] = useState(0); // Dynamic gridSize

  const currentGameState = history.length > 0 ? history[history.length - 1] : initialGameState; // Added check for history.length
  const { board, currentPlayer } = currentGameState;

  useEffect(() => {
    //人机对战从这里触发
    workerRef.current = new Worker(new URL('../games/gomoku/gomoku.worker.ts', import.meta.url), { type: 'module' });
    workerRef.current.onmessage = (e) => {
      const { row, col } = e.data;
      if (row !== null && col !== null) {
        // AI makes a move. The new makeMove function gets the player from the current state.
        makeMove(row, col);
      }
    };
    return () => workerRef.current?.terminate();
  }, []);

  // Triggers the AI's turn when history changes
  useEffect(() => {
    if (gameMode === 'hva' && currentPlayer === 'white' && !winner) {
      workerRef.current?.postMessage({ board, player: 'white' });
    }
  }, [history, gameMode, winner]);

  // Effect to calculate and update gridSize on mount and window resize
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

  const makeMove = (row: number, col: number) => {
    // Use functional updates to ensure we're always working with the latest state.
    // This prevents issues with stale closures in callbacks like the worker's onmessage.
    setHistory(prevHistory => {
      const currentGameState = prevHistory[prevHistory.length - 1];
      const { board, currentPlayer } = currentGameState;

      // If the game is won or the square is already taken, do nothing.
      if (winner || board[row][col]) {
        return prevHistory;
      }

      const newBoard = board.map(r => [...r]);
      newBoard[row][col] = currentPlayer;

      const newWinner = checkWin(newBoard, row, col, currentPlayer) ? currentPlayer : null;
      if (newWinner) {
        setWinner(newWinner);
      }

      const opponent = currentPlayer === 'black' ? 'white' : 'black';
      const nextState: GameState = { board: newBoard, currentPlayer: opponent };

      return [...prevHistory, nextState];
    });
  };

  const handleClick = (event: React.MouseEvent<SVGSVGElement>) => {
    // Prevent human player from moving when it's AI's turn
    if (gameMode === 'hva' && currentPlayer === 'white') return;

    const rect = event.currentTarget.getBoundingClientRect();
    const x = event.clientX - rect.left - gridSize / 2;
    const y = event.clientY - rect.top - gridSize / 2;
    const col = Math.round(x / gridSize);
    const row = Math.round(y / gridSize);

    if (col >= 0 && col < boardSize && row >= 0 && row < boardSize) {
      // The player is now determined inside makeMove from the latest state.
      makeMove(row, col);
    }
  };

  const handleUndo = () => {
    if (history.length > 1 && !winner) {
      const stepsToUndo = (gameMode === 'hva' && currentPlayer === 'white' && history.length > 2) ? 2 : 1;
      setHistory(history.slice(0, 0 - stepsToUndo));
    }
  };

  const handleSave = () => window.electronAPI.saveGame(currentGameState);

  const handleLoad = async () => {
    const loadedState = await window.electronAPI.loadGame() as GameState;
    if (loadedState && loadedState.board && loadedState.currentPlayer) {
      setHistory([loadedState]);
      setWinner(null);
    }
  };

  const resetGame = () => {
    setHistory([initialGameState]);
    setWinner(null);
  };

  // Calculate board dimensions based on dynamic gridSize
  const boardPixelSize = boardSize * gridSize;

  if (gridSize === 0) {
    // Render a loading state or placeholder until gridSize is calculated
    return <div ref={boardContainerRef} style={{ width: '100%', height: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>Loading Board...</div>;
  }

  return (
    <div ref={boardContainerRef} style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
      <div ref={boardWrapperRef} style={{ flexGrow: 1, display: 'flex', justifyContent: 'center', alignItems: 'center', width: '100%' }}>
        <svg width={boardPixelSize} height={boardPixelSize} style={{ border: '2px solid black', backgroundColor: '#dcb35c', cursor: 'pointer' }} onClick={handleClick}>
          <g transform={`translate(${gridSize / 2}, ${gridSize / 2})`}>
            {Array.from({ length: boardSize }).map((_, i) => (
              <g key={i}>
                <line x1={0} y1={i * gridSize} x2={(boardSize - 1) * gridSize} y2={i * gridSize} stroke="black" />
                <line x1={i * gridSize} y1={0} x2={i * gridSize} y2={(boardSize - 1) * gridSize} stroke="black" />
              </g>
            ))}
            {board.map((row, r) => 
              row.map((cell, c) => 
                cell && <circle key={`${r}-${c}`} cx={c * gridSize} cy={r * gridSize} r={gridSize / 2 - 2} fill={cell} stroke="gray" strokeWidth="1" />
              )
            )}
          </g>
        </svg>
      </div>
      <div style={{ height: '30px', fontWeight: 'bold', marginTop: '10px' }}>
        {!winner ? `Current Player: ${currentPlayer.toUpperCase()}` : `Winner: ${winner.toUpperCase()}!`}
      </div>
      <div style={{ textAlign: 'center', marginTop: '10px' }}>
        <select onChange={(e) => setGameMode(e.target.value as GameMode)} value={gameMode} disabled={history.length > 1} style={{ marginRight: '10px' }}>
          <option value="hvh">Human vs. Human</option>
          <option value="hva">Human vs. AI</option>
        </select>
        <button onClick={handleSave}>Save</button>
        <button onClick={handleLoad}>Load</button>
        <button onClick={handleUndo} disabled={history.length <= 1 || !!winner}>Undo</button>
        <button onClick={resetGame}>Reset Game</button>
      </div>
    </div>
  );
};

export default GomokuBoard;
