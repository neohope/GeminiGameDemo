
import React, { useState, useEffect, useRef } from 'react';
import '../types'; // Ensure global types are loaded
import { isMoveValid } from '../games/chess/chessLogic';

// --- Types and Constants ---
type Player = 'white' | 'black';
type PieceType = 'pawn' | 'rook' | 'knight' | 'bishop' | 'queen' | 'king';
type Piece = { type: PieceType; color: Player; };
type Board = (Piece | null)[][];
type GameState = { board: Board; currentPlayer: Player; };
type GameMode = 'hvh' | 'hva';

const boardSize = 8;

const pieceUnicode = {
  white: { king: '♔', queen: '♕', rook: '♖', bishop: '♗', knight: '♘', pawn: '♙' },
  black: { king: '♚', queen: '♛', rook: '♜', bishop: '♝', knight: '♞', pawn: '♟︎' },
};

const initialBoard: Board = [
  [{type: 'rook', color: 'black'}, {type: 'knight', color: 'black'}, {type: 'bishop', color: 'black'}, {type: 'queen', color: 'black'}, {type: 'king', color: 'black'}, {type: 'bishop', color: 'black'}, {type: 'knight', color: 'black'}, {type: 'rook', color: 'black'}],
  Array.from({ length: 8 }, () => ({type: 'pawn', color: 'black'})),
  Array(8).fill(null), Array(8).fill(null), Array(8).fill(null), Array(8).fill(null),
  Array.from({ length: 8 }, () => ({type: 'pawn', color: 'white'})),
  [{type: 'rook', color: 'white'}, {type: 'knight', color: 'white'}, {type: 'bishop', color: 'white'}, {type: 'queen', color: 'white'}, {type: 'king', color: 'white'}, {type: 'bishop', color: 'white'}, {type: 'knight', color: 'white'}, {type: 'rook', color: 'white'}],
];

// --- React Component ---
const ChessBoard: React.FC = () => {
  const [history, setHistory] = useState<GameState[]>([{ board: initialBoard, currentPlayer: 'white' }]);
  const [selected, setSelected] = useState<[number, number] | null>(null);
  const [gameMode, setGameMode] = useState<GameMode>('hvh');
  const workerRef = useRef<Worker | null>(null);
  const boardContainerRef = useRef<HTMLDivElement>(null);
  const [gridSize, setGridSize] = useState(0); // Dynamic gridSize

  const currentGameState = history[history.length - 1];
  const { board, currentPlayer } = currentGameState;

  useEffect(() => {
    workerRef.current = new Worker(new URL('../games/chess/chess.worker.ts', import.meta.url), { type: 'module' });
    workerRef.current.onmessage = (e) => {
      const bestMove = e.data;
      if (bestMove) {
        // The new movePiece function handles getting the latest state.
        movePiece(bestMove.from, bestMove.to);
      }
    };
    return () => workerRef.current?.terminate();
  }, []);

  useEffect(() => {
    // Post the latest board state to the AI worker when it's AI's turn
    if (gameMode === 'hva' && currentPlayer === 'black') {
      workerRef.current?.postMessage({ board, player: 'black' });
    }
  }, [board, currentPlayer, gameMode]);

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



// --- React Component ---

  const movePiece = (from: [number, number], to: [number, number]) => {
    // Use functional updates to ensure we're always working with the latest state.
    setHistory(prevHistory => {
      const currentGameState = prevHistory[prevHistory.length - 1];
      const { board, currentPlayer } = currentGameState;

      if (!isMoveValid(board, from, to)) {
        // If the move is invalid, deselect the piece and don't update history.
        setSelected(null);
        return prevHistory;
      }

      const newBoard = board.map(r => [...r]);
      newBoard[to[0]][to[1]] = newBoard[from[0]][from[1]];
      newBoard[from[0]][from[1]] = null;

      const nextPlayer = currentPlayer === 'white' ? 'black' : 'white';
      const nextState = { board: newBoard, currentPlayer: nextPlayer };

      return [...prevHistory, nextState];
    });

    // Deselect piece after a move is attempted.
    setSelected(null);
  };

  const handleClick = (row: number, col: number) => {
    if (gameMode === 'hva' && currentPlayer === 'black') return;

    if (selected) {
      // A piece is selected, try to move it.
      movePiece(selected, [row, col]);
    } else if (board[row][col]?.color === currentPlayer) {
      // No piece is selected, select the clicked piece if it belongs to the current player.
      setSelected([row, col]);
    }
  };

  const handleUndo = () => {
    if (history.length > 1) {
      const steps = (gameMode === 'hva' && currentPlayer === 'white' && history.length > 2) ? 2 : 1;
      setHistory(history.slice(0, -steps));
    }
  };

  const handleSave = () => window.electronAPI.saveGame(currentGameState);
  const handleLoad = async () => {
    const loadedState = await window.electronAPI.loadGame() as GameState;
    if (loadedState && loadedState.board && loadedState.currentPlayer) {
      setHistory([loadedState]);
    }
  };

  const resetGame = () => setHistory([{ board: initialBoard, currentPlayer: 'white' }]);

  if (gridSize === 0) {
    return <div ref={boardContainerRef} style={{ width: '100%', height: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>Loading Board...</div>;
  }

  return (
    <div ref={boardContainerRef} style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ width: boardSize * gridSize, height: boardSize * gridSize, display: 'flex', flexWrap: 'wrap' }}>
        {board.map((row, r) => 
          row.map((piece, c) => (
            <div 
              key={`${r}-${c}`} 
              onClick={() => handleClick(r, c)}
              style={{
                width: gridSize, height: gridSize, 
                backgroundColor: (r + c) % 2 === 0 ? '#f0d9b5' : '#b58863',
                color: piece?.color === 'white' ? '#ffffff' : '#000000',
                fontSize: gridSize * 0.7, display: 'flex', justifyContent: 'center', alignItems: 'center', cursor: 'pointer',
                outline: selected && selected[0] === r && selected[1] === c ? '2px solid blue' : 'none',
                outlineOffset: '-2px' // Draw outline inside the element to prevent layout shift
              }}
            >
              {piece && pieceUnicode[piece.color][piece.type]}
            </div>
          ))
        )}
      </div>
      <div style={{fontWeight: 'bold', marginTop: '10px'}}>Current Player: {currentPlayer.toUpperCase()}</div>
      <div style={{textAlign: 'center', marginTop: '10px'}}>
        <select onChange={(e) => setGameMode(e.target.value as GameMode)} value={gameMode} disabled={history.length > 1}>
          <option value="hvh">Human vs. Human</option>
          <option value="hva">Human vs. AI</option>
        </select>
        <button onClick={handleUndo} disabled={history.length <= 1}>Undo</button>
        <button onClick={handleSave}>Save</button>
        <button onClick={handleLoad}>Load</button>
        <button onClick={resetGame}>Reset</button>
      </div>
    </div>
  );
};

export default ChessBoard;
