// import 'dart:ui';

// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flutter/material.dart';
// import 'package:multiplayer_game_demo/game_service.dart';

// class GridComponent extends PositionComponent with TapCallbacks {
//   static const int gridSize = 5;
//   final GameService _gameService;
//   final String playerId;
//   final Function(Map<String, int>) updateScores;

//   Map<String, String> gridState = {}; // Estado actual de la cuadrícula
//   Map<String, int> scores = {}; // Puntaje acumulado de cada jugador

//   GridComponent(this.playerId, this._gameService, {required this.updateScores});

//   @override
//   void render(Canvas canvas) {
//     final cellSize = size.x / gridSize;
//     final borderPaint = Paint()..color = const Color(0xFF000000);

//     for (int row = 0; row < gridSize; row++) {
//       for (int col = 0; col < gridSize; col++) {
//         final cellKey = '$row$col';
//         final playerInCell = gridState[cellKey];
//         final cellPaint = Paint()
//           ..color = playerInCell == null
//               ? const Color(0xFFFFFFFF)
//               : (playerInCell == playerId ? Colors.green : Colors.red);

//         canvas.drawRect(
//           Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
//           cellPaint,
//         );

//         canvas.drawRect(
//           Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
//           borderPaint..style = PaintingStyle.stroke,
//         );
//       }
//     }
//   }

//   @override
//   void onTapDown(TapDownEvent event) {
//     final cellSize = size.x / gridSize;
//     final col = (event.localPosition.x / cellSize).floor();
//     final row = (event.localPosition.y / cellSize).floor();
//     final cellKey = '$row$col';

//     // Reemplazar el cuadro del enemigo
//     _gameService.movePlayer(playerId, cellKey);
//     scores[playerId] = (scores[playerId] ?? 0) + 1;
//     updateScores(scores);
//   }

//   @override
//   Future<void> onLoad() async {
//     super.onLoad();
//     size = Vector2(size.x, size.y);

//     _gameService.gridStream.listen((event) {
//       final data = event.snapshot.value;
//       if (data != null && data is Map) {
//         gridState = Map<String, String>.from(data);
//         updateScores(_calculateScores());
//       } else {
//         gridState = {};
//       }
//     });
//   }

//   Map<String, int> _calculateScores() {
//     final newScores = <String, int>{};
//     for (final player in gridState.values) {
//       newScores[player] = (newScores[player] ?? 0) + 1;
//     }
//     return newScores;
//   }
// }

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:multiplayer_game_demo/game_service.dart';

class GridComponent extends PositionComponent with TapCallbacks {
  static const int gridSize = 5;
  final GameService _gameService;
  final String playerId;
  final Function(Map<String, int>) updateScores;

  Map<String, String> gridState = {};

  GridComponent(this.playerId, this._gameService, {required this.updateScores});

  @override
  void render(Canvas canvas) {
    final cellSize = size.x / gridSize;
    final borderPaint = Paint()..color = const Color(0xFF000000);

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final cellKey = '$row$col';
        final playerInCell = gridState[cellKey];
        final cellPaint = Paint()
          ..color = playerInCell == null
              ? const Color(0xFFFFFFFF)
              : (playerInCell == playerId ? Colors.green : Colors.red);

        canvas.drawRect(
          Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
          cellPaint,
        );

        canvas.drawRect(
          Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
          borderPaint..style = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final cellSize = size.x / gridSize;
    final col = (event.localPosition.x / cellSize).floor();
    final row = (event.localPosition.y / cellSize).floor();
    final cellKey = '$row$col';

    _gameService.movePlayer(playerId, cellKey);
    updateScores(_calculateScores());
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _gameService.gridStream.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        gridState = Map<String, String>.from(data);
        updateScores(_calculateScores());
      } else {
        gridState = {};
      }
    });
  }

  Map<String, int> _calculateScores() {
    final scores = <String, int>{};
    for (final player in gridState.values) {
      scores[player] = (scores[player] ?? 0) + 1;
    }
    return scores;
  }
}
