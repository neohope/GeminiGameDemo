import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('electronAPI', {
  saveGame: (gameState: unknown) => ipcRenderer.invoke('save-game', gameState),
  loadGame: () => ipcRenderer.invoke('load-game'),
});
