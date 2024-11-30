import 'package:firebase_database/firebase_database.dart';

class GameService {
  final DatabaseReference _gameRef = FirebaseDatabase.instance.ref('game');

  // Incrementar contador de jugadores listos
  Future<void> incrementReadyCounter() async {
    final counterRef = _gameRef.child('readyCounter');
    final currentValue = (await counterRef.get()).value as int? ?? 0;
    await counterRef.set(currentValue + 1);
  }

  // Stream para el contador de jugadores listos
  Stream<DatabaseEvent> get readyStream =>
      _gameRef.child('readyCounter').onValue;

  // Iniciar el juego
  Future<void> startGame() async {
    await _gameRef.child('gameStarted').set(true);
  }

  // Stream para saber si el juego ha iniciado
  Stream<DatabaseEvent> get startStream =>
      _gameRef.child('gameStarted').onValue;

  // Limpiar la cuadrícula
  Future<void> clearGrid() async {
    await _gameRef.child('grid').remove();
  }

  // Stream para el reinicio del juego
  Stream<DatabaseEvent> get restartStream =>
      _gameRef.child('restartCounter').onValue;

  // Incrementar contador de reinicios
  Future<void> incrementRestartCounter() async {
    final counterRef = _gameRef.child('restartCounter');
    final currentValue = (await counterRef.get()).value as int? ?? 0;
    await counterRef.set(currentValue + 1);
  }

  // Resetear contador de reinicios
  Future<void> resetRestartCounter() async {
    await _gameRef.child('restartCounter').set(0);
  }

  // Stream para los cambios en la cuadrícula
  Stream<DatabaseEvent> get gridStream => _gameRef.child('grid').onValue;

  // Mover un jugador a una celda
  Future<void> movePlayer(String playerId, String cellKey) async {
    await _gameRef.child('grid').child(cellKey).set(playerId);
  }
}
