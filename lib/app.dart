import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

class BricleApp extends StatelessWidget {
  const BricleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BRICLE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE3000B),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.fredokaTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
