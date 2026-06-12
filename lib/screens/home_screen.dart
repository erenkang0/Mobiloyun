import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/brick.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/brick_widget.dart';
import 'game_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_DecorBrick> _decors;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    final rng = Random(99);
    _decors = List.generate(8, (i) => _DecorBrick(rng, i));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame(GameMode mode) {
    ref.read(gameModeProvider.notifier).state = mode;
    ref.read(gameProvider.notifier).reset(mode);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GameScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            ..._decors.map((d) => _FloatingBrick(ctrl: _controller, decor: d)),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'BRICLE',
                      style: GoogleFonts.fredoka(
                        fontSize: 80,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 6,
                        shadows: const [
                          Shadow(color: Color(0xFFE3000B), offset: Offset(5, 5)),
                          Shadow(color: Color(0xFFFFD700), offset: Offset(10, 10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rastgele tuğlalarla yarat!',
                      style: GoogleFonts.fredoka(
                        fontSize: 17,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 64),
                    _HomeButton(
                      label: 'SERBEST YAP',
                      color: const Color(0xFF00A850),
                      icon: Icons.grid_view_rounded,
                      onTap: () => _startGame(GameMode.freeBuild),
                    ),
                    const SizedBox(height: 18),
                    _HomeButton(
                      label: 'MEYDAN OKU',
                      color: const Color(0xFFE3000B),
                      icon: Icons.flag_rounded,
                      onTap: () => _startGame(GameMode.challenge),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorBrick {
  final double x;
  final double speed;
  final double phase;
  final String brickId;
  final int w;
  final int h;
  final Color color;

  _DecorBrick(Random rng, int i)
      : x = rng.nextDouble(),
        speed = 0.15 + rng.nextDouble() * 0.6,
        phase = rng.nextDouble(),
        brickId = 'decor_$i',
        w = 1 + rng.nextInt(3),
        h = 1 + rng.nextInt(2),
        color = legoColors[rng.nextInt(legoColors.length)];
}

class _FloatingBrick extends StatelessWidget {
  final AnimationController ctrl;
  final _DecorBrick decor;

  const _FloatingBrick({required this.ctrl, required this.decor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, child) {
        final t = (ctrl.value * decor.speed + decor.phase) % 1.0;
        return Positioned(
          left: decor.x * size.width - 20,
          top: t * (size.height + 80) - 80,
          child: Opacity(
            opacity: 0.12,
            child: Transform.rotate(
              angle: t * 2 * pi,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: decor.w * 24.0,
        height: decor.h * 24.0,
        decoration: BoxDecoration(
          color: decor.color,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.black26),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  Color _darken(Color c, double amt) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness - amt).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 62,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              offset: const Offset(0, 6),
              blurRadius: 16,
            ),
            BoxShadow(
              color: _darken(color, 0.28),
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
