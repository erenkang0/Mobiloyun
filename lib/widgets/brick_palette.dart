import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import 'brick_widget.dart';

class BrickPalette extends ConsumerWidget {
  const BrickPalette({super.key});

  static const double _cellSize = 28.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return Container(
      height: 140,
      color: const Color(0xFF1E1E2E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 8, bottom: 2),
            child: Text(
              'TUĞLALAR  —  Seç ve grid\'e yerleştir',
              style: GoogleFonts.fredokaOne(
                fontSize: 11,
                color: Colors.white38,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: gameState.palette.isEmpty
                ? Center(
                    child: TextButton.icon(
                      onPressed: notifier.refreshPalette,
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      label: Text(
                        'Yeni Tuğlalar',
                        style: GoogleFonts.fredokaOne(color: Colors.white70),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: gameState.palette.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, i) {
                      final brick = gameState.palette[i];
                      final isSelected = gameState.selectedBrickId == brick.id;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Draggable<String>(
                            data: brick.id,
                            feedback: Material(
                              color: Colors.transparent,
                              child: BrickWidget(
                                brick: brick,
                                cellSize: _cellSize,
                                isSelected: true,
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.25,
                              child: BrickWidget(brick: brick, cellSize: _cellSize),
                            ),
                            onDragStarted: () => notifier.selectBrick(brick.id),
                            child: BrickWidget(
                              brick: brick,
                              cellSize: _cellSize,
                              isSelected: isSelected,
                              onTap: () => notifier.selectBrick(isSelected ? null : brick.id),
                            ),
                          ),
                          if (isSelected)
                            GestureDetector(
                              onTap: () => notifier.rotateBrick(brick.id),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Icon(Icons.rotate_right, color: Colors.white60, size: 18),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
