// ignore_for_file: unused_field

import 'package:firebase_database/firebase_database.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer_game_demo/game/components/grid.dart';
import '../game_service.dart';

class GameManager extends FlameGame {
  final GameService _gameService = GameService();
  final String playerId;
  final ValueNotifier<Map<String, int>> scoresNotifier = ValueNotifier({});
  int restartCounter = 0;
  int _player1Score = 0;
  int _player2Score = 0;

  GameManager(this.playerId);

  @override
  Color backgroundColor() => const Color(0xFFDDDDDD);

  Stream<DatabaseEvent> get startStream => _gameService.startStream;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Tamaño completo del canvas
    final gridSize = size.clone();

    // Agregar la cuadrícula
    add(GridComponent(
      playerId,
      _gameService,
      updateScores: updateScores,
    )..size = gridSize);
  }

  void updateScores(Map<String, int> scores) {
    scoresNotifier.value = scores;
  }

  void _updateScores(Map<String, int> scores) {
    scoresNotifier.value = scores;
    _player1Score = scores['player1'] ?? 0;
    _player2Score = scores['player2'] ?? 0;
  }

  void endGame() {
    final scores = scoresNotifier.value;
    final player1Score = scores['player1'] ?? 0;
    final player2Score = scores['player2'] ?? 0;

    String message;
    if (player1Score > player2Score) {
      message = playerId == 'player1' ? '¡Ganaste!' : '¡Perdiste!';
    } else if (player2Score > player1Score) {
      message = playerId == 'player2' ? '¡Ganaste!' : '¡Perdiste!';
    } else {
      message = '¡Es un empate!';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: buildContext!,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
            content: const Text(
                'Esperando que ambos jugadores presionen reiniciar...'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  _registerRestart();
                  Navigator.of(context).pop();
                },
                child: const Text('Reiniciar'),
              ),
            ],
          );
        },
      );
    });
  }

  void _registerRestart() {
    restartCounter++;
    _gameService.incrementRestartCounter(); // Incrementar en Firebase

    _gameService.restartStream.listen((event) {
      final count = event.snapshot.value as int? ?? 0;
      if (count >= 2) {
        _gameService.resetRestartCounter();
        restartGame();
      }
    });
  }

  void restartGame() {
    restartCounter = 0;
    _player1Score = 0;
    _player2Score = 0;
    scoresNotifier.value = {};
    _gameService.clearGrid();

    overlays.clear();
    add(GridComponent(playerId, _gameService, updateScores: _updateScores)
      ..size = size.clone());
  }

  void notifyReady() {
    _gameService.incrementReadyCounter();

    _gameService.readyStream.listen((event) {
      final readyCount = event.snapshot.value as int? ?? 0;
      if (readyCount >= 2) {
        _gameService.startGame();
      }
    });
  }
}
