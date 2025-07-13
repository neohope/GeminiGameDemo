import React, { useState } from 'react';
import HomeScreen from './views/HomeScreen';
import GameScreen from './views/GameScreen';

type Game = 'gomoku' | 'chinese_chess' | 'go' | 'chess';

const App: React.FC = () => {
  const [selectedGame, setSelectedGame] = useState<Game | null>(null);

  const handleSelectGame = (game: Game) => {
    setSelectedGame(game);
  };

  const handleBackToMenu = () => {
    setSelectedGame(null);
  };

  if (!selectedGame) {
    return <HomeScreen onSelectGame={handleSelectGame} />;
  }

  return <GameScreen game={selectedGame} onBack={handleBackToMenu} />;
};

export default App;
