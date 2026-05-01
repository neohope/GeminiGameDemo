import 'storage_service.dart';

class GameStorage {
  final StorageService _storage;

  GameStorage(this._storage);

  static const String _saveKeyPrefix = 'save_';

  Future<void> saveGame(String gameId, Map<String, dynamic> gameState) async {
    final saveData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'state': gameState,
    };
    await _storage.saveJson('$_saveKeyPrefix$gameId', saveData);
  }

  Map<String, dynamic>? loadGame(String gameId) {
    final saveData = _storage.getJson('$_saveKeyPrefix$gameId');
    if (saveData == null) return null;
    return saveData['state'] as Map<String, dynamic>?;
  }

  Future<void> deleteSave(String gameId) async {
    await _storage.remove('$_saveKeyPrefix$gameId');
  }

  bool hasSave(String gameId) {
    return _storage.getString('$_saveKeyPrefix$gameId') != null;
  }
}
