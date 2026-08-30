import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const VideoEditorApp());

class VideoEditorApp extends StatelessWidget {
  const VideoEditorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0B0D14),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7F77DD),
        secondary: Color(0xFFD4537E),
        surface: Color(0xFF1A1D28),
      ),
      cardColor: Colors.white.withOpacity(0.06),
      dividerColor: Colors.white.withOpacity(0.14),
    ),
    home: const HomeScreen(),
  );
}
