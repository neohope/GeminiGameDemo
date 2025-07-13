export interface IElectronAPI {
  saveGame: (gameState: unknown) => Promise<void>;
  loadGame: () => Promise<unknown | null>;
}

declare global {
  interface Window {
    electronAPI: IElectronAPI;
  }
}

export type GameState = unknown; // Add this export to ensure file is treated as a module
