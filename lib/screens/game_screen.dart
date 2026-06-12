import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/grid_widget.dart';
import '../widgets/brick_palette.dart';
import 'result_screen.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'BRICLE',
              style: GoogleFonts.fredokaOne(
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 2,
              ),
            ),
            if (gameState.mode == GameMode.challenge)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3000B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'MEYDAN',
                  style: GoogleFonts.fredokaOne(fontSize: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${gameState.score} pts',
                style: GoogleFonts.fredokaOne(
                  color: const Color(0xFFFFD700),
                  fontSize: 20,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            onPressed: notifier.undoLast,
            tooltip: 'Geri al',
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(score: gameState.score),
              ),
            ),
            child: Text(
              'BİTİR',
              style: GoogleFonts.fredokaOne(
                color: const Color(0xFF00A850),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const GridWidget(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const BrickPalette(),
        ],
      ),
    );
  }
}
