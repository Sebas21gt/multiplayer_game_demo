// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../game_service.dart';

class PlayerController extends StatefulWidget {
  final String playerId;
  final String color;

  const PlayerController({
    required this.playerId,
    required this.color,
    super.key,
  });

  @override
  _PlayerControllerState createState() => _PlayerControllerState();
}

class _PlayerControllerState extends State<PlayerController> {
  final GameService _gameService = GameService();
  late String _cellKey; // La celda que el jugador ocupa actualmente.

  @override
  void initState() {
    super.initState();
    _cellKey = "0_0"; // Posición inicial del jugador.
    _gameService.movePlayer(
        widget.playerId, _cellKey); // Reclama la posición inicial.
  }

  void _movePlayer(String direction) async {
    final currentPosition = _cellKey.split('_').map(int.parse).toList();
    int row = currentPosition[0];
    int col = currentPosition[1];

    switch (direction) {
      case 'up':
        if (row > 0) row--;
        break;
      case 'down':
        if (row < 4) row++;
        break;
      case 'left':
        if (col > 0) col--;
        break;
      case 'right':
        if (col < 4) col++;
        break;
    }

    final newCellKey = '${row}_${col}';
    await _gameService.movePlayer(widget.playerId, newCellKey);
    setState(() {
      _cellKey = newCellKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jugador: ${widget.playerId}'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Usa los botones para moverte', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _movePlayer('up'),
                child: const Icon(Icons.arrow_upward),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _movePlayer('left'),
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => _movePlayer('right'),
                child: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _movePlayer('down'),
                child: const Icon(Icons.arrow_downward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
