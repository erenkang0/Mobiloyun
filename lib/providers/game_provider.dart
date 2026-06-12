import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/brick.dart';
import '../models/game_state.dart';

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(GameMode mode) : super(GameState.initial(mode));

  final List<GameState> _history = [];

  void placeBrick(String brickId, Point<int> position) {
    final brickIndex = state.palette.indexWhere((b) => b.id == brickId);
    if (brickIndex == -1) return;
    final brick = state.palette[brickIndex];
    if (!state.canPlace(brick, position)) return;

    _history.add(state);

    final newGrid = state.grid.map((row) => List<String?>.from(row)).toList();
    for (int r = 0; r < brick.effectiveHeight; r++) {
      for (int c = 0; c < brick.effectiveWidth; c++) {
        newGrid[position.y + r][position.x + c] = brickId;
      }
    }

    final placed = brick.copyWith(gridPosition: position);
    final bonus = state.challengeBonus(brick, position);

    state = state.copyWith(
      palette: state.palette.where((b) => b.id != brickId).toList(),
      placed: [...state.placed, placed],
      grid: newGrid,
      score: state.score + 10 + bonus,
      clearSelection: true,
    );
  }

  void rotateBrick(String brickId) {
    final idx = state.palette.indexWhere((b) => b.id == brickId);
    if (idx == -1) return;
    final updated = List<Brick>.from(state.palette);
    final brick = updated[idx];
    updated[idx] = brick.copyWith(rotation: (brick.rotation + 90) % 360);
    state = state.copyWith(palette: updated);
  }

  void selectBrick(String? brickId) {
    if (brickId == null) {
      state = state.copyWith(clearSelection: true);
    } else {
      state = state.copyWith(selectedBrickId: brickId);
    }
  }

  void undoLast() {
    if (_history.isEmpty) return;
    state = _history.removeLast();
  }

  void refreshPalette() {
    _history.add(state);
    final existing = state.palette.length;
    final newBricks = List.generate(
      8 - existing,
      (i) => Brick.random('brick_${DateTime.now().millisecondsSinceEpoch}_$i'),
    );
    state = state.copyWith(palette: [...state.palette, ...newBricks]);
  }

  void reset(GameMode mode) {
    _history.clear();
    state = GameState.initial(mode);
  }
}

final gameModeProvider = StateProvider<GameMode>((ref) => GameMode.freeBuild);

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final mode = ref.watch(gameModeProvider);
  return GameNotifier(mode);
});
