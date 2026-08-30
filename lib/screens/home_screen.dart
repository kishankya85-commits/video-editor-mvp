import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/media_service.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _media = MediaService();

  Future<void> _newProject() async {
    final File? file = await _media.pickVideo();
    if (!mounted || file == null) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(sourcePath: file.path)));
  }

  Widget _glassButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 260,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: onPressed == null ? Colors.white38 : Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(color: onPressed == null ? Colors.white38 : Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Video Editor'), backgroundColor: Colors.transparent),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _glassButton(icon: Icons.add, label: 'New Project', onPressed: _newProject),
          const SizedBox(height: 14),
          _glassButton(icon: Icons.folder_open, label: 'Open Project (not implemented yet)', onPressed: null),
        ],
      ),
    ),
  );
}
