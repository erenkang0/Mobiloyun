import 'dart:math';
import 'brick.dart';

enum GameMode { freeBuild, challenge }

class GameState {
  static const int gridSize = 16;

  final List<Brick> palette;
  final List<Brick> placed;
  final List<List<String?>> grid;
  final int score;
  final GameMode mode;
  final List<List<bool>>? target;
  final String? selectedBrickId;

  const GameState({
    required this.palette,
    required this.placed,
    required this.grid,
    required this.score,
    required this.mode,
    this.target,
    this.selectedBrickId,
  });

  factory GameState.initial(GameMode mode) {
    final grid = List.generate(
      gridSize,
      (_) => List<String?>.filled(gridSize, null),
    );
    final palette = List.generate(8, (i) => Brick.random('brick_$i'));
    return GameState(
      palette: palette,
      placed: [],
      grid: grid,
      score: 0,
      mode: mode,
      target: mode == GameMode.challenge ? _generateTarget() : null,
    );
  }

  static List<List<bool>> _generateTarget() {
    final rng = Random();
    final target = List.generate(gridSize, (_) => List<bool>.filled(gridSize, false));
    final startRow = 2 + rng.nextInt(4);
    final startCol = 2 + rng.nextInt(4);
    for (int r = startRow; r < startRow + 8 && r < gridSize; r++) {
      for (int c = startCol; c < startCol + 8 && c < gridSize; c++) {
        if (rng.nextBool()) target[r][c] = true;
      }
    }
    return target;
  }

  bool canPlace(Brick brick, Point<int> pos) {
    for (int r = 0; r < brick.effectiveHeight; r++) {
      for (int c = 0; c < brick.effectiveWidth; c++) {
        final row = pos.y + r;
        final col = pos.x + c;
        if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) return false;
        if (grid[row][col] != null) return false;
      }
    }
    return true;
  }

  int challengeBonus(Brick brick, Point<int> pos) {
    if (target == null) return 0;
    int bonus = 0;
    for (int r = 0; r < brick.effectiveHeight; r++) {
      for (int c = 0; c < brick.effectiveWidth; c++) {
        final row = pos.y + r;
        final col = pos.x + c;
        if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
          if (target![row][col]) bonus += 20;
        }
      }
    }
    return bonus;
  }

  GameState copyWith({
    List<Brick>? palette,
    List<Brick>? placed,
    List<List<String?>>? grid,
    int? score,
    GameMode? mode,
    List<List<bool>>? target,
    String? selectedBrickId,
    bool clearSelection = false,
  }) {
    return GameState(
      palette: palette ?? this.palette,
      placed: placed ?? this.placed,
      grid: grid ?? this.grid,
      score: score ?? this.score,
      mode: mode ?? this.mode,
      target: target ?? this.target,
      selectedBrickId: clearSelection ? null : (selectedBrickId ?? this.selectedBrickId),
    );
  }
}
