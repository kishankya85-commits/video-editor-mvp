import 'dart:io';
import 'package:flutter/material.dart';
import '../services/media_service.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState()=>_HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  final _media = MediaService();
  Future<void> _newProject() async {
    final File? file = await _media.pickVideo();
    if (!mounted || file == null) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(sourcePath: file.path)));
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Video Editor'), backgroundColor: Colors.transparent),
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      FilledButton.icon(onPressed: _newProject, icon: const Icon(Icons.add), label: const Text('New Project')),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.folder_open), label: const Text('Open Project (not implemented yet)')),
    ])),
  );
}
