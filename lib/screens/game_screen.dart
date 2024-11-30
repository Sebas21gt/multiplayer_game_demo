import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/game_manager.dart';

class GameScreen extends StatefulWidget {
  final String playerId;

  const GameScreen({required this.playerId, Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameManager _gameManager;
  int _secondsLeft = 30; // Tiempo inicial
  bool _gameStarted = false; // Estado de inicio del juego
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _gameManager = GameManager(widget.playerId);

    // Escuchar el estado de inicio
    _gameManager.startStream.listen((event) {
      final started = event.snapshot.value as bool? ?? false;
      if (started) {
        setState(() {
          _gameStarted = true;
          _startTimer();
        });
      }
    });

    // Notificar que este jugador está listo
    _gameManager.notifyReady();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 30; // Reiniciar el tiempo
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
          _gameManager.endGame(); // Finalizar el juego
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Esperando al otro jugador...',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego Multijugador'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Información de tiempo y puntaje
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tiempo restante: $_secondsLeft s',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ValueListenableBuilder<Map<String, int>>(
                  valueListenable: _gameManager.scoresNotifier,
                  builder: (context, scores, child) {
                    final player1Score = scores['player1'] ?? 0;
                    final player2Score = scores['player2'] ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Jugador 1: $player1Score',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Jugador 2: $player2Score',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Juego
          Expanded(
            child: GameWidget(game: _gameManager),
          ),
        ],
      ),
    );
  }
}
