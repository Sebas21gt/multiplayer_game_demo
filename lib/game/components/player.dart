import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerComponent extends PositionComponent {
  final String playerId;
  final Color color;

  PlayerComponent({
    required this.playerId,
    required this.color,
    required Vector2 position,
  }) {
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 3, // Tamaño del jugador
      paint,
    );
  }

  @override
  Future<void> onLoad() async {
    size = Vector2(50, 50); // Tamaño del jugador
  }
}
