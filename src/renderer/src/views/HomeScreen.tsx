import React from 'react';
import './HomeScreen.css'; // Import the new CSS file

type Props = {
  onSelectGame: (game: string) => void;
};

const GameCard: React.FC<{ icon: string; name: string; subtitle: string; onClick: () => void }> = ({ icon, name, subtitle, onClick }) => (
  <div className="game-card" onClick={onClick}>
    <div className="game-icon">{icon}</div>
    <div className="game-name">{name}</div>
    <div className="game-subtitle">{subtitle}</div>
  </div>
);

const HomeScreen: React.FC<Props> = ({ onSelectGame }) => {
  return (
    <div className="home-screen">
      <h1 className="home-title">Gemini Game Suite</h1>
      <p className="home-subtitle">Select a game to begin</p>
      <div className="game-selection-container">
        <GameCard icon="⚫" name="Gomoku" subtitle="五子棋" onClick={() => onSelectGame('gomoku')} />
        <GameCard icon="帥" name="Chinese Chess" subtitle="中国象棋" onClick={() => onSelectGame('chinese_chess')} />
        <GameCard icon="弈" name="Go" subtitle="围棋" onClick={() => onSelectGame('go')} />
        <GameCard icon="♔" name="Chess" subtitle="国际象棋" onClick={() => onSelectGame('chess')} />
      </div>
    </div>
  );
};

export default HomeScreen;
