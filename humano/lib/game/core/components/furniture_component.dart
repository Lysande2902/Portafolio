import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

enum FurnitureType {
  chair,
  table,
  bookshelf,
  bed,
  lamp,
  rug,
  mirror, // Especial para el Arco 1
  plant,
  clock,
  cabinet
}

class FurnitureComponent extends PositionComponent with HasGameReference {
  final FurnitureType type;
  final int variant; // Para diferentes colores o estilos
  final bool isSolid; // Si bloquea el paso
  
  FurnitureComponent({
    required Vector2 position,
    required this.type,
    this.variant = 0,
    this.isSolid = true,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Cargar el spritesheet completo
    final image = await game.images.load('sprites/furniture.png');
    
    // Definir la región de recorte según el tipo (Coordenadas aproximadas basadas en tilesets estándar)
    // Nota: Estas coordenadas deberán ajustarse visualmente
    Rect srcRect;
    Vector2 sizeOverride;

    switch (type) {
      case FurnitureType.chair:
        srcRect = Rect.fromLTWH(0 + (variant * 32.0), 32, 32, 32); 
        sizeOverride = Vector2(32, 32);
        break;
      case FurnitureType.table:
        srcRect = Rect.fromLTWH(0 + (variant * 32.0), 0, 32, 32);
        sizeOverride = Vector2(32, 32);
        break;
      case FurnitureType.bookshelf:
        srcRect = Rect.fromLTWH(128, 96, 32, 64);
        sizeOverride = Vector2(32, 64);
        break;
      case FurnitureType.bed:
        srcRect = Rect.fromLTWH(0, 160, 32, 64);
        sizeOverride = Vector2(32, 64);
        break;
      case FurnitureType.rug:
        srcRect = Rect.fromLTWH(128, 160, 32, 64); 
        sizeOverride = Vector2(32, 64);
        break;
      case FurnitureType.mirror:
        srcRect = Rect.fromLTWH(0, 224, 32, 32);
        sizeOverride = Vector2(32, 32);
        break;
      default:
        srcRect = const Rect.fromLTWH(0, 0, 32, 32);
        sizeOverride = Vector2(32, 32);
    }

    size = sizeOverride;

    // Crear el sprite recortado
    final sprite = Sprite(
      image,
      srcPosition: Vector2(srcRect.left, srcRect.top),
      srcSize: Vector2(srcRect.width, srcRect.height),
    );

    add(SpriteComponent(
      sprite: sprite,
      size: size,
    ));

    // Añadir colisión si es sólido
    if (isSolid) {
      // Hitbox ligeramente más pequeña para permitir overlap visual
      add(RectangleHitbox(
        position: Vector2(0, size.y * 0.5), 
        size: Vector2(size.x, size.y * 0.5),
      ));
    }
  }
}
