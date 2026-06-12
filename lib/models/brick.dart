import 'dart:math';
import 'package:flutter/material.dart';

const legoColors = [
  Color(0xFFE3000B), // kırmızı
  Color(0xFFFFD700), // sarı
  Color(0xFF006CB7), // mavi
  Color(0xFF00A850), // yeşil
  Color(0xFFFF7200), // turuncu
  Color(0xFF9C27B0), // mor
  Color(0xFF00BCD4), // cyan
  Color(0xFFFF69B4), // pembe
  Color(0xFFFFFFFF), // beyaz
  Color(0xFF444444), // siyah
];

class Brick {
  final String id;
  final int width;
  final int height;
  final Color color;
  final int rotation; // 0, 90, 180, 270
  final Point<int>? gridPosition;

  const Brick({
    required this.id,
    required this.width,
    required this.height,
    required this.color,
    this.rotation = 0,
    this.gridPosition,
  });

  int get effectiveWidth => rotation == 90 || rotation == 270 ? height : width;
  int get effectiveHeight => rotation == 90 || rotation == 270 ? width : height;

  Brick copyWith({
    String? id,
    int? width,
    int? height,
    Color? color,
    int? rotation,
    Point<int>? gridPosition,
    bool clearPosition = false,
  }) {
    return Brick(
      id: id ?? this.id,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      rotation: rotation ?? this.rotation,
      gridPosition: clearPosition ? null : (gridPosition ?? this.gridPosition),
    );
  }

  static Brick random(String id) {
    final rng = Random();
    const sizes = [
      (1, 1), (1, 2), (2, 1), (2, 2),
      (1, 3), (3, 1), (1, 4), (4, 1),
    ];
    final size = sizes[rng.nextInt(sizes.length)];
    final color = legoColors[rng.nextInt(legoColors.length)];
    return Brick(
      id: id,
      width: size.$2,
      height: size.$1,
      color: color,
    );
  }
}
