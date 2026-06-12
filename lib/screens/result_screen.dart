import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/brick.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  const ResultScreen({super.key, required this.score});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  final List<_ConfettiPiece> _pieces = List.generate(50, (_) => _ConfettiPiece());

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _scale = CurvedAnimation(
      parent: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..forward(),
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => CustomPaint(
                painter: _ConfettiPainter(_pieces, _ctrl.value),
                size: MediaQuery.of(context).size,
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 90)),
                    const SizedBox(height: 16),
                    Text(
                      'TEBRİKLER!',
                      style: GoogleFonts.fredokaOne(
                        fontSize: 52,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: const [
                          Shadow(color: Color(0xFFFFD700), offset: Offset(4, 4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.score} PUAN',
                      style: GoogleFonts.fredokaOne(
                        fontSize: 40,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(height: 52),
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (_) => false,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A850),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF00A850),
                              offset: Offset(0, 5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Text(
                          'YENİ OYUN',
                          style: GoogleFonts.fredokaOne(
                            fontSize: 26,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
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

class _ConfettiPiece {
  final double x = Random().nextDouble();
  final double speed = 0.15 + Random().nextDouble() * 0.85;
  final double phase = Random().nextDouble();
  final double size = 6 + Random().nextDouble() * 10;
  final double drift = (Random().nextDouble() - 0.5) * 30;
  final Color color = legoColors[Random().nextInt(legoColors.length)];

  static const legoColors = [
    Color(0xFFE3000B),
    Color(0xFFFFD700),
    Color(0xFF006CB7),
    Color(0xFF00A850),
    Color(0xFFFF7200),
    Color(0xFFFF69B4),
  ];
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double t;

  const _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final progress = (t * p.speed + p.phase) % 1.0;
      final y = progress * (size.height + 60) - 30;
      final x = p.x * size.width + sin(t * 3 + p.phase * 6) * p.drift;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * 4 * pi);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        Paint()..color = p.color,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
