import React, { useState, useEffect, useRef } from 'react';
import { isValidMove, isKingInCheck, isGameOver, Piece, Player, Board } from '../games/chinese_chess/chineseChessLogic';
import { IElectronAPI } from '../types';

const initialPiecesData: Omit<Piece, 'id'>[] = [
  { x: 0, y: 0, text: '車', color: 'red' }, { x: 1, y: 0, text: '馬', color: 'red' }, { x: 2, y: 0, text: '相', color: 'red' }, { x: 3, y: 0, text: '仕', color: 'red' }, { x: 4, y: 0, text: '帥', color: 'red' }, { x: 5, y: 0, text: '仕', color: 'red' }, { x: 6, y: 0, text: '相', color: 'red' }, { x: 7, y: 0, text: '馬', color: 'red' }, { x: 8, y: 0, text: '車', color: 'red' },
  { x: 1, y: 2, text: '炮', color: 'red' }, { x: 7, y: 2, text: '炮', color: 'red' },
  { x: 0, y: 3, text: '兵', color: 'red' }, { x: 2, y: 3, text: '兵', color: 'red' }, { x: 4, y: 3, text: '兵', color: 'red' }, { x: 6, y: 3, text: '兵', color: 'red' }, { x: 8, y: 3, text: '兵', color: 'red' },
  { x: 0, y: 9, text: '車', color: 'black' }, { x: 1, y: 9, text: '馬', color: 'black' }, { x: 2, y: 9, text: '象', color: 'black' }, { x: 3, y: 9, text: '士', color: 'black' }, { x: 4, y: 9, text: '將', color: 'black' }, { x: 5, y: 9, text: '士', color: 'black' }, { x: 6, y: 9, text: '象', color: 'black' }, { x: 7, y: 9, text: '馬', color: 'black' }, { x: 8, y: 9, text: '車', color: 'black' },
  { x: 1, y: 7, text: '砲', color: 'black' }, { x: 7, y: 7, text: '砲', color: 'black' },
  { x: 0, y: 6, text: '卒', color: 'black' }, { x: 2, y: 6, text: '卒', color: 'black' }, { x: 4, y: 6, text: '卒', color: 'black' }, { x: 6, y: 6, text: '卒', color: 'black' }, { x: 8, y: 6, text: '卒', color: 'black' },
];

const initialPieces = initialPiecesData.map((p, i) => ({ ...p, id: i }));

type GameHistory = { pieces: Board; currentPlayer: Player; };
type GameMode = 'hvh' | 'hva';

const ChineseChessBoard: React.FC = () => {
  const [history, setHistory] = useState<GameHistory[]>([{ pieces: initialPieces, currentPlayer: 'red' }]);
  const [selectedPiece, setSelectedPiece] = useState<Piece | null>(null);
  const [checkStatus, setCheckStatus] = useState<Player | null>(null);
  const [gameOverStatus, setGameOverStatus] = useState<'checkmate' | 'stalemate' | null>(null);
  const [gameMode, setGameMode] = useState<GameMode>('hvh');
  const workerRef = useRef<Worker | null>(null);
  const boardContainerRef = useRef<HTMLDivElement>(null);
  const boardSvgWrapperRef = useRef<HTMLDivElement>(null);
  const [gridSize, setGridSize] = useState(0); // Dynamic gridSize

  const currentGameState = history[history.length - 1];
  const { pieces, currentPlayer } = currentGameState;

  useEffect(() => {
    workerRef.current = new Worker(new URL('../games/chinese_chess/chineseChess.worker.ts', import.meta.url), { type: 'module' });
    workerRef.current.onmessage = (e) => {
      const bestMove = e.data;
      if (bestMove) {
        // The piece object from the worker might be stale. We only need the coordinates.
        // The new movePiece function will find the correct piece from the latest state.
        movePiece(bestMove.piece.x, bestMove.piece.y, bestMove.toX, bestMove.toY);
      }
    };
    return () => workerRef.current?.terminate();
  }, []);

  useEffect(() => {
    if (gameOverStatus) return;
    const check = isKingInCheck(currentPlayer, pieces);
    setCheckStatus(check ? currentPlayer : null);

    const gameOver = isGameOver(currentPlayer, pieces);
    if (gameOver) {
      setGameOverStatus(gameOver);
    } else if (gameMode === 'hva' && currentPlayer === 'black') {
      // Post the latest board state to the AI worker
      workerRef.current?.postMessage({ board: pieces, player: 'black' });
    }
  }, [pieces, currentPlayer, gameMode, gameOverStatus]);

  // Effect to calculate and update gridSize on mount and window resize
  useEffect(() => {
    const calculateGridSize = () => {
      if (boardContainerRef.current) {
        const { clientWidth, clientHeight } = boardContainerRef.current;
        const svgWidthUnits = 9;
        const svgHeightUnits = 10;
        const containerAspectRatio = clientWidth / clientHeight;
        const svgAspectRatio = svgWidthUnits / svgHeightUnits;
        let newGridSize;
        if (containerAspectRatio > svgAspectRatio) {
          newGridSize = Math.floor(clientHeight / svgHeightUnits);
        } else {
          newGridSize = Math.floor(clientWidth / svgWidthUnits);
        }
        setGridSize(newGridSize);
      }
    };

    calculateGridSize();
    window.addEventListener('resize', calculateGridSize);

    return () => {
      window.removeEventListener('resize', calculateGridSize);
    };
  }, []);

  const movePiece = (fromX: number, fromY: number, toX: number, toY: number) => {
    // Use functional updates to prevent issues with stale state in callbacks.
    setHistory(prevHistory => {
      if (gameOverStatus) return prevHistory; // Check game over status inside the update

      const currentGameState = prevHistory[prevHistory.length - 1];
      const { pieces, currentPlayer } = currentGameState;

      const pieceToMove = pieces.find(p => p.x === fromX && p.y === fromY);
      if (!pieceToMove) return prevHistory;

      // Create a new board state for the move
      let newPieces = pieces.filter(p => !(p.x === toX && p.y === toY)); // Remove captured piece
      newPieces = newPieces.map(p => p.id === pieceToMove.id ? { ...p, x: toX, y: toY } : p); // Move piece

      // Check for illegal moves (moving into check)
      if (isKingInCheck(pieceToMove.color, newPieces)) {
        console.log("You cannot move into check!");
        setSelectedPiece(null); // Deselect piece on illegal move
        return prevHistory; // Revert to previous state
      }

      const nextPlayer = currentPlayer === 'red' ? 'black' : 'red';
      const nextState = { pieces: newPieces, currentPlayer: nextPlayer };

      return [...prevHistory, nextState];
    });

    // Deselect piece after a move is made
    setSelectedPiece(null);
  };

  const handleBoardClick = (event: React.MouseEvent<SVGSVGElement>) => {
    if (!selectedPiece || (gameMode === 'hva' && currentPlayer === 'black')) return;
    const rect = event.currentTarget.getBoundingClientRect();
    const x = event.clientX - rect.left - gridSize / 2;
    const y = event.clientY - rect.top - gridSize / 2;
    const toX = Math.round(x / gridSize);
    const toY = Math.round(y / gridSize);

    if (isValidMove(selectedPiece, toX, toY, pieces, true)) {
      movePiece(selectedPiece.x, selectedPiece.y, toX, toY);
    }
  };

  const handlePieceClick = (piece: Piece, event: React.MouseEvent) => {
    event.stopPropagation();
    if (gameOverStatus || (gameMode === 'hva' && currentPlayer === 'black')) return;

    if (selectedPiece) {
      if (piece.color !== selectedPiece.color) {
        if (isValidMove(selectedPiece, piece.x, piece.y, pieces, true)) {
          movePiece(selectedPiece.x, selectedPiece.y, piece.x, piece.y);
        } else {
          setSelectedPiece(piece.color === currentPlayer ? piece : null);
        }
      } else {
        setSelectedPiece(piece);
      }
    } else if (piece.color === currentPlayer) {
      setSelectedPiece(piece);
    }
  };

  const handleUndo = () => {
    if (history.length > 1 && !gameOverStatus) {
      const stepsToUndo = (gameMode === 'hva' && currentPlayer === 'white' && history.length > 2) ? 2 : 1;
      setHistory(history.slice(0, -stepsToUndo));
      setSelectedPiece(null);
    }
  };

  const handleSave = () => {
    (window.electronAPI as IElectronAPI).saveGame(currentGameState);
  };

  const handleLoad = async () => {
    const loadedState = await (window.electronAPI as IElectronAPI).loadGame() as GameHistory;
    if (loadedState && loadedState.pieces && loadedState.currentPlayer) {
      setHistory([loadedState]);
      setSelectedPiece(null);
      setCheckStatus(null);
      setGameOverStatus(null);
    }
  };

  const resetGame = () => {
    setHistory([{ pieces: initialPieces, currentPlayer: 'red' }]);
    setSelectedPiece(null);
    setCheckStatus(null);
    setGameOverStatus(null);
  };

  // Calculate board dimensions based on dynamic gridSize
  const boardPixelWidth = 8 * gridSize;
  const boardPixelHeight = 9 * gridSize;

  if (gridSize === 0) {
    // Render a loading state or placeholder until gridSize is calculated
    return <div ref={boardContainerRef} style={{ width: '100%', height: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>Loading Board...</div>;
  }

  return (
    <div ref={boardContainerRef} style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      <div style={{textAlign: 'center', height: '30px', color: 'red', fontWeight: 'bold'}}>
        {gameOverStatus ? `${gameOverStatus.toUpperCase()}! ${currentPlayer === 'red' ? 'Black' : 'Red'} wins.` : (checkStatus && `${checkStatus.toUpperCase()} is in Check!`)}
      </div>
      <div style={{ flex: 1, display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
        <svg width={boardPixelWidth + gridSize} height={boardPixelHeight + gridSize} style={{ border: '2px solid black', backgroundColor: '#f0d9b5' }} onClick={handleBoardClick}>
          <g transform={`translate(${gridSize / 2}, ${gridSize / 2})`}>
            {/* Grid Lines */}
            {Array.from({ length: 10 }).map((_, row) => (<line key={`h-${row}`} x1={0} y1={row * gridSize} x2={boardPixelWidth} y2={row * gridSize} stroke="black" />))}
            {Array.from({ length: 9 }).map((_, col) => (<line key={`v-${col}`} x1={col * gridSize} y1={0} x2={col * gridSize} y2={boardPixelHeight} stroke="black" />))}
            {/* River */}
            <text x={boardPixelWidth / 2} y={4.5 * gridSize} textAnchor="middle" dominantBaseline="middle" fontSize={gridSize * 0.6} fill="#a0a0a0">楚河 漢界</text>
            {/* Palaces */}
            <line x1={3 * gridSize} y1={0} x2={5 * gridSize} y2={2 * gridSize} stroke="black" />
            <line x1={5 * gridSize} y1={0} x2={3 * gridSize} y2={2 * gridSize} stroke="black" />
            <line x1={3 * gridSize} y1={7 * gridSize} x2={5 * gridSize} y2={9 * gridSize} stroke="black" />
            <line x1={5 * gridSize} y1={7 * gridSize} x2={3 * gridSize} y2={9 * gridSize} stroke="black" />
            {/* Pieces */}
            {pieces.map((piece) => {
              const isKing = piece.text === '帥' || piece.text === '將';
              const isInCheck = isKing && checkStatus === piece.color;
              return (
                <g key={piece.id} transform={`translate(${piece.x * gridSize}, ${piece.y * gridSize})`} onClick={(e) => handlePieceClick(piece, e)} style={{ cursor: 'pointer' }}>
                  <circle r={gridSize / 2 - 2} fill={isInCheck ? 'orange' : (piece.color === 'red' ? '#ffcccc' : '#d3d3d3')} stroke={selectedPiece?.id === piece.id ? 'blue' : 'black'} strokeWidth="3" />
                  <text textAnchor="middle" dominantBaseline="middle" fontSize={gridSize / 2} fill={piece.color} style={{ pointerEvents: 'none' }}>{piece.text}</text>
                </g>
              );
            })}
          </g>
        </svg>
      </div>
      <div style={{height: '30px', fontWeight: 'bold', textAlign: 'center', marginTop: '10px'}}>
        { !gameOverStatus && `Current Player: ${currentPlayer.toUpperCase()}` }
      </div>
      <div style={{textAlign: 'center', marginTop: '10px', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '10px'}}>
        <select onChange={(e) => setGameMode(e.target.value as GameMode)} value={gameMode} disabled={history.length > 1}>
          <option value="hvh">Human vs. Human</option>
          <option value="hva">Human vs. AI</option>
        </select>
        <button onClick={handleUndo} disabled={history.length <= 1 || !!gameOverStatus}>Undo</button>
        <button onClick={handleSave}>Save</button>
        <button onClick={handleLoad}>Load</button>
        <button onClick={resetGame}>Reset Game</button>
      </div>
    </div>
  );
};

export default ChineseChessBoard;
