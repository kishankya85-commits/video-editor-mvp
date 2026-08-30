import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const VideoEditorApp());
class VideoEditorApp extends StatelessWidget {
  const VideoEditorApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, colorSchemeSeed: Colors.deepPurple, scaffoldBackgroundColor: const Color(0xFF12151C), useMaterial3: true),
    home: const HomeScreen(),
  );
}
