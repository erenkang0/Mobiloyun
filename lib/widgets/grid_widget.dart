import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import 'brick_widget.dart';

class GridWidget extends ConsumerStatefulWidget {
  const GridWidget({super.key});

  @override
  ConsumerState<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends ConsumerState<GridWidget> {
  Point<int>? _hoverCell;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    const gridSize = GameState.gridSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / gridSize;
        return Stack(
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxWidth,
              child: CustomPaint(
                painter: GridPainter(
                  gridSize: gridSize,
                  cellSize: cellSize,
                  target: gameState.target,
                ),
              ),
            ),
            ..._buildPlacedBricks(gameState, cellSize),
            if (gameState.selectedBrickId != null)
              _buildInteractiveLayer(gridSize, cellSize, gameState),
          ],
        );
      },
    );
  }

  List<Widget> _buildPlacedBricks(GameState gameState, double cellSize) {
    return gameState.placed.map((brick) {
      final pos = brick.gridPosition!;
      return Positioned(
        left: pos.x * cellSize,
        top: pos.y * cellSize,
        child: BrickWidget(brick: brick, cellSize: cellSize),
      );
    }).toList();
  }

  Widget _buildInteractiveLayer(int gridSize, double cellSize, GameState gameState) {
    final selected = gameState.palette.firstWhere(
      (b) => b.id == gameState.selectedBrickId,
    );
    return Positioned.fill(
      child: GestureDetector(
        onTapDown: (d) {
          final col = (d.localPosition.dx / cellSize).floor().clamp(0, gridSize - 1);
          final row = (d.localPosition.dy / cellSize).floor().clamp(0, gridSize - 1);
          final pos = Point(col, row);
          if (gameState.canPlace(selected, pos)) {
            ref.read(gameProvider.notifier).placeBrick(selected.id, pos);
            setState(() => _hoverCell = null);
          }
        },
        onPanUpdate: (d) {
          setState(() {
            _hoverCell = Point(
              (d.localPosition.dx / cellSize).floor().clamp(0, gridSize - 1),
              (d.localPosition.dy / cellSize).floor().clamp(0, gridSize - 1),
            );
          });
        },
        onPanEnd: (_) {
          if (_hoverCell != null && gameState.canPlace(selected, _hoverCell!)) {
            ref.read(gameProvider.notifier).placeBrick(selected.id, _hoverCell!);
          }
          setState(() => _hoverCell = null);
        },
        child: Stack(
          children: [
            if (_hoverCell != null)
              Positioned(
                left: _hoverCell!.x * cellSize,
                top: _hoverCell!.y * cellSize,
                child: Opacity(
                  opacity: gameState.canPlace(selected, _hoverCell!) ? 0.65 : 0.25,
                  child: BrickWidget(brick: selected, cellSize: cellSize),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int gridSize;
  final double cellSize;
  final List<List<bool>>? target;

  const GridPainter({
    required this.gridSize,
    required this.cellSize,
    this.target,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFD6CEBC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (target != null) {
      final targetPaint = Paint()..color = const Color(0x40006CB7);
      final borderPaint = Paint()
        ..color = const Color(0x80006CB7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (target![r][c]) {
            final rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
            canvas.drawRect(rect, targetPaint);
            canvas.drawRect(rect, borderPaint);
          }
        }
      }
    }

    final linePaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 0.5;
    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), linePaint);
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) => old.target != target;
}
