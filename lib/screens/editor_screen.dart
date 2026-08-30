import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/audio_track.dart';
import '../models/text_overlay.dart';
import '../models/caption.dart';
import '../models/project_template.dart';
import '../models/export_models.dart';
import '../models/timeline_clip.dart';
import '../services/audio_service.dart';
import '../services/export_service.dart';
import '../services/project_service.dart';
import '../services/storage_service.dart';
import '../services/backup_service.dart';
import '../services/template_service.dart';
import '../services/media_service.dart';
import '../widgets/audio_timeline.dart';
import '../widgets/text_overlay_editor.dart';
import '../widgets/export_sheet.dart';
import '../widgets/caption_editor.dart';
import '../widgets/template_sheet.dart';
import '../widgets/timeline_editor.dart';

class EditorScreen extends StatefulWidget {
  final String sourcePath;
  const EditorScreen({super.key, required this.sourcePath});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  static const Duration _minClipDuration = Duration(milliseconds: 500);

  final MediaService _mediaService = MediaService();
  final AudioService _audioService = AudioService();
  final ExportService _exportService = ExportService();
  final ProjectService _projectService = ProjectService();
  final StorageService _storageService = StorageService();
  final BackupService _backupService = BackupService();
  final TemplateService _templateService = TemplateService();
  VideoPlayerController? _controller;

  List<TimelineClip> _clips = const [];
  List<AudioTrack> _audioTracks = const [];
  List<TextOverlay> _textOverlays = const [];
  List<Caption> _captions = const [];
  int? _selectedTextIndex;
  int _selectedIndex = 0;
  int? _selectedAudioIndex;
  Duration _projectPosition = Duration.zero;
  bool _seeking = false;
  bool _switchingClip = false;
  bool _disposed = false;
  bool _saving = false;
  ExportResolution _exportResolution = ExportResolution.p720;
  ExportState _exportState = const ExportState();

  TimelineClip get _selectedClip => _clips[_selectedIndex];
  Duration get _projectDuration =>
      _clips.fold(Duration.zero, (sum, clip) => sum + clip.duration);

  Duration _projectStartFor(int index) => _clips
      .take(index)
      .fold(Duration.zero, (sum, clip) => sum + clip.duration);

  @override
  void initState() {
    super.initState();
    _openInitialClip();
  }

  Future<void> _openInitialClip() async {
    await _replaceController(widget.sourcePath);
    if (!mounted || _controller == null) return;
    final duration = _controller!.value.duration;
    setState(() {
      _clips = [TimelineClip(
        id: 'clip-${DateTime.now().microsecondsSinceEpoch}',
        sourcePath: widget.sourcePath,
        sourceDuration: duration,
        start: Duration.zero,
        end: duration,
      )];
    });
  }

  Future<void> _replaceController(String path) async {
    final old = _controller;
    if (old != null) {
      old.removeListener(_onPlayerChanged);
      await old.pause();
      await old.dispose();
    }
    final next = VideoPlayerController.file(File(path));
    _controller = next;
    await next.initialize();
    next.addListener(_onPlayerChanged);
    if (mounted) setState(() {});
  }

  void _onPlayerChanged() {
    if (!mounted || _seeking || _switchingClip || _controller == null || _clips.isEmpty) return;
    final position = _controller!.value.position;
    final clip = _selectedClip;

    if (position >= clip.end) {
      if (_selectedIndex < _clips.length - 1) {
        _continueToNextClip();
      } else {
        _controller!.pause();
        _seekProject(_projectDuration);
      }
      return;
    }

    final p = _projectStartFor(_selectedIndex) + (position - clip.start);
    if (p != _projectPosition) setState(() => _projectPosition = p);
  }

  Future<void> _continueToNextClip() async {
    if (_switchingClip || _selectedIndex >= _clips.length - 1) return;
    _switchingClip = true;
    await _selectClip(_selectedIndex + 1, autoplay: true);
    _switchingClip = false;
  }

  Future<void> _selectClip(int index, {bool autoplay = false}) async {
    if (index < 0 || index >= _clips.length) return;
    final clip = _clips[index];
    _seeking = true;
    if (_selectedIndex != index) setState(() => _selectedIndex = index);
    if (_controller?.dataSource != clip.sourcePath) await _replaceController(clip.sourcePath);
    await _controller?.seekTo(clip.start);
    if (autoplay) await _controller?.play();
    if (mounted) setState(() => _projectPosition = _projectStartFor(index));
    _seeking = false;
  }

  Future<void> _seekProject(Duration requested) async {
    if (_clips.isEmpty || _controller == null) return;
    var target = requested;
    if (target < Duration.zero) target = Duration.zero;
    if (target > _projectDuration) target = _projectDuration;

    var cursor = Duration.zero;
    var index = _clips.length - 1;
    var sourcePosition = _clips.last.end;
    for (var i = 0; i < _clips.length; i++) {
      final next = cursor + _clips[i].duration;
      if (target < next || i == _clips.length - 1) {
        index = i;
        sourcePosition = _clips[i].start + (target - cursor);
        if (sourcePosition > _clips[i].end) sourcePosition = _clips[i].end;
        break;
      }
      cursor = next;
    }

    _seeking = true;
    if (_selectedIndex != index) setState(() => _selectedIndex = index);
    if (_controller!.dataSource != _clips[index].sourcePath) {
      await _replaceController(_clips[index].sourcePath);
    }
    await _controller!.seekTo(sourcePosition);
    if (mounted) setState(() => _projectPosition = target);
    _seeking = false;
  }

  Future<void> _togglePlay() async {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      if (_projectPosition >= _projectDuration) await _seekProject(Duration.zero);
      await _controller!.play();
    }
  }

  void _replaceSelected(TimelineClip c) {
    setState(() {
      final next = [..._clips];
      next[_selectedIndex] = c;
      _clips = next;
    });
    _scheduleSave();
  }

  void _trimStart(Duration delta) {
    final clip = _selectedClip;
    var start = clip.start + delta;
    if (start < Duration.zero) start = Duration.zero;
    if (start > clip.end - _minClipDuration) start = clip.end - _minClipDuration;
    _replaceSelected(clip.copyWith(start: start));
  }

  void _trimEnd(Duration delta) {
    final clip = _selectedClip;
    var end = clip.end + delta;
    if (end > clip.sourceDuration) end = clip.sourceDuration;
    if (end < clip.start + _minClipDuration) end = clip.start + _minClipDuration;
    _replaceSelected(clip.copyWith(end: end));
  }

  void _splitAtPlayhead() {
    final clip = _selectedClip;
    final split = clip.start + (_projectPosition - _projectStartFor(_selectedIndex));
    if (split <= clip.start + _minClipDuration || split >= clip.end - _minClipDuration) {
      _message('Playhead must be 0.5s away from clip edges.');
      return;
    }
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final left = TimelineClip(id: '${clip.id}-l-$stamp', sourcePath: clip.sourcePath, sourceDuration: clip.sourceDuration, start: clip.start, end: split);
    final right = TimelineClip(id: '${clip.id}-r-$stamp', sourcePath: clip.sourcePath, sourceDuration: clip.sourceDuration, start: split, end: clip.end);
    setState(() {
      _clips = [..._clips.take(_selectedIndex), left, right, ..._clips.skip(_selectedIndex + 1)];
      _selectedIndex++;
    });
    _scheduleSave();
    _seekProject(_projectPosition);
  }

  Future<void> _addVideos() async {
    final files = await _mediaService.pickVideos();
    if (!mounted) return;
    final added = <TimelineClip>[];
    for (final file in files) {
      final probe = VideoPlayerController.file(file);
      try {
        await probe.initialize();
        if (probe.value.duration > Duration.zero) {
          added.add(TimelineClip(
            id: 'clip-${DateTime.now().microsecondsSinceEpoch}-${added.length}',
            sourcePath: file.path,
            sourceDuration: probe.value.duration,
            start: Duration.zero,
            end: probe.value.duration,
          ));
        }
      } finally {
        await probe.dispose();
      }
    }
    if (added.isNotEmpty) {
      setState(() => _clips = [..._clips, ...added]);
      _scheduleSave();
    }
  }

  Future<void> _deleteSelected() async {
    if (_clips.length <= 1) {
      _message('The project must contain at least one clip.');
      return;
    }
    final next = [..._clips]..removeAt(_selectedIndex);
    final index = _selectedIndex >= next.length ? next.length - 1 : _selectedIndex;
    setState(() { _clips = next; _selectedIndex = index; });
    await _selectClip(index);
    _scheduleSave();
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final selectedId = _selectedClip.id;
    final next = [..._clips];
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    final selected = next.indexWhere((e) => e.id == selectedId);
    setState(() { _clips = next; _selectedIndex = selected; });
    await _selectClip(selected);
    _scheduleSave();
  }

  Future<void> _addAudio({required bool background}) async {
    File? file;
    try {
      file = await _audioService.pickAudio();
    } catch (e) {
      if (mounted) _message('Could not import audio: $e');
      return;
    }
    if (!mounted || file == null) return;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    setState(() {
      _audioTracks = [..._audioTracks, AudioTrack(
        id: 'audio-$stamp',
        sourcePath: file.path,
        sourceDuration: _projectDuration,
        start: Duration.zero,
        end: _projectDuration,
        timelineStart: Duration.zero,
        volume: 1.0,
        isBackgroundMusic: background,
      )];
      _selectedAudioIndex = _audioTracks.length - 1;
    });
    _scheduleSave();
    _message('Audio added. It will be included in Step 7 export.');
  }

  void _trimSelectedAudioStart(Duration delta) {
    final i = _selectedAudioIndex;
    if (i == null) return;
    final t = _audioTracks[i];
    var start = t.start + delta;
    if (start < Duration.zero) start = Duration.zero;
    if (start > t.end - _minClipDuration) start = t.end - _minClipDuration;
    _updateAudio(i, t.copyWith(start: start));
  }

  void _trimSelectedAudioEnd(Duration delta) {
    final i = _selectedAudioIndex;
    if (i == null) return;
    final t = _audioTracks[i];
    var end = t.end + delta;
    if (end < t.start + _minClipDuration) end = t.start + _minClipDuration;
    _updateAudio(i, t.copyWith(end: end));
  }

  void _setAudioVolume(double value) {
    final i = _selectedAudioIndex;
    if (i == null) return;
    _updateAudio(i, _audioTracks[i].copyWith(volume: value));
  }

  void _updateAudio(int index, AudioTrack track) {
    setState(() {
      final next = [..._audioTracks];
      next[index] = track;
      _audioTracks = next;
    });
  }


  void _addTextOverlay() {
    final end = _projectDuration > const Duration(seconds: 3)
        ? const Duration(seconds: 3)
        : _projectDuration;
    final overlay = TextOverlay(
      id: 'text-${DateTime.now().microsecondsSinceEpoch}',
      text: 'New Text',
      x: .5,
      y: .5,
      fontSize: 28,
      color: Colors.white,
      fontWeight: FontWeight.normal,
      startTime: _projectPosition,
      endTime: _projectPosition + end > _projectDuration
          ? _projectDuration
          : _projectPosition + end,
    );
    setState(() {
      _textOverlays = [..._textOverlays, overlay];
      _selectedTextIndex = _textOverlays.length - 1;
    });
    _scheduleSave();
  }

  void _updateSelectedText(TextOverlay overlay) {
    final index = _selectedTextIndex;
    if (index == null) return;
    setState(() {
      final next = [..._textOverlays];
      next[index] = overlay;
      _textOverlays = next;
    });
    _scheduleSave();
  }

  void _deleteSelectedText() {
    final index = _selectedTextIndex;
    if (index == null) return;
    setState(() {
      final next = [..._textOverlays]..removeAt(index);
      _textOverlays = next;
      _selectedTextIndex = null;
    });
    _scheduleSave();
  }

  void _moveTextOverlay(int index, Offset delta, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final overlay = _textOverlays[index];
    final x = (overlay.x + delta.dx / size.width).clamp(.05, .95);
    final y = (overlay.y + delta.dy / size.height).clamp(.05, .95);
    _selectedTextIndex = index;
    _updateSelectedText(overlay.copyWith(x: x, y: y));
  }




  void _addCaption() {
    final start = _projectPosition;
    final end = (start + const Duration(seconds: 3) > _projectDuration)
        ? _projectDuration : start + const Duration(seconds: 3);
    setState(() => _captions = [..._captions, Caption(
      id: 'caption-${DateTime.now().microsecondsSinceEpoch}',
      text: 'Edit caption text', start: start, end: end,
    )]);
    _scheduleSave();
  }

  void _deleteCaption(int index) {
    setState(() { final next=[..._captions]..removeAt(index); _captions=next; });
    _scheduleSave();
  }


  Future<void> _saveAsTemplate() async {
    if (_clips.isEmpty) { _message('Add at least one clip before saving a template.'); return; }
    final controller=TextEditingController(text:'My Template');
    final description=TextEditingController();
    final result=await showDialog<List<String>>(context:context,builder:(context)=>AlertDialog(
      title:const Text('Save Template'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:controller,decoration:const InputDecoration(labelText:'Template name')),
        TextField(controller:description,decoration:const InputDecoration(labelText:'Description')),
      ]),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),
        FilledButton(onPressed:()=>Navigator.pop(context,[controller.text.trim(),description.text.trim()]),child:const Text('Save')),
      ],
    ));
    if(result==null || result.first.isEmpty) return;
    final template=ProjectTemplate(
      id:'template-${DateTime.now().microsecondsSinceEpoch}',
      name:result.first,description:result.last,createdAt:DateTime.now(),
      clipPaths:_clips.map((c)=>c.sourcePath).toList(),
      textOverlays:_textOverlays.map((t)=>{'text':t.text,'x':t.x,'y':t.y,'fontSize':t.fontSize,'color':t.color.value,'fontWeight':t.fontWeight.index,'startMs':t.startTime.inMilliseconds,'endMs':t.endTime.inMilliseconds}).toList(),
      captions:_captions.map((c)=>{'text':c.text,'startMs':c.start.inMilliseconds,'endMs':c.end.inMilliseconds}).toList(),
    );
    try { await _templateService.save(template); if(mounted)_message('Template saved.'); } catch(e){if(mounted)_message('Template save failed: $e');}
  }

  Future<void> _showTemplates() async {
    final templates=await _templateService.listTemplates();
    if(!mounted)return;
    await showModalBottomSheet(context:context,isScrollControlled:true,builder:(context)=>TemplateSheet(
      templates:templates,
      onApply:(t){ Navigator.pop(context); _message('Template selected. Template loading into editor is the next implementation step.'); },
      onDelete:(t) async { await _templateService.delete(t.id); if(context.mounted) Navigator.pop(context); if(mounted)_showTemplates(); },
    ));
  }

  Future<void> _createBackup() async {
    await _saveProjectState();
    try {
      final file = await _backupService.createBackup(_projectService);
      if (mounted) _message('Backup created: ${file.path}');
    } catch (e) { if (mounted) _message('Backup failed: $e'); }
  }

  Future<void> _restoreLatestBackup() async {
    try {
      final backups=await _backupService.listBackups();
      if(backups.isEmpty) { if(mounted) _message('No backup found.'); return; }
      await _backupService.restore(backups.first,_projectService);
      if(mounted) _message('Latest backup restored. Reopen the project to load restored state.');
    } catch(e) { if(mounted) _message('Restore failed: $e'); }
  }

  Future<void> _clearTempStorage() async {
    try {
      await _storageService.clearTemp();
      final bytes=await _storageService.tempUsageBytes();
      if(mounted) _message('Temporary files cleaned. Remaining cache: $bytes bytes.');
    } catch(e) { if(mounted) _message('Storage cleanup failed: $e'); }
  }

  Future<void> _saveProjectState() async {
    if (_saving || _clips.isEmpty) return;
    _saving = true;
    try {
      await _projectService.save(
        clips: _clips,
        audioTracks: _audioTracks,
        textOverlays: _textOverlays,
        captions: _captions,
      );
    } catch (_) {
      // Editing remains usable even if persistence fails.
    } finally {
      _saving = false;
    }
  }

  void _scheduleSave() {
    _saveProjectState();
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => ExportSheet(
          resolution: _exportResolution,
          onResolutionChanged: (r) {
            setState(() => _exportResolution = r);
            setSheetState(() {});
          },
          state: _exportState,
          onCancel: () async {
            await _exportService.cancel();
          },
          onExport: () async {
            if (_clips.isEmpty) {
              setState(() => _exportState = const ExportState(
                status: ExportStatus.error,
                error: 'Add at least one video clip before exporting.',
              ));
              setSheetState(() {});
              return;
            }
            if (_exportState.status == ExportStatus.exporting) return;
            setState(() => _exportState = const ExportState(status: ExportStatus.exporting, progress: 0));
            setSheetState(() {});
            ExportState result;
            try {
              result = await _exportService.exportProject(
                clips: _clips,
                audioTracks: _audioTracks,
                textOverlays: _textOverlays,
                resolution: _exportResolution,
                onProgress: (p) {
                  if (!mounted || _disposed) return;
                  setState(() => _exportState = _exportState.copyWith(
                    status: ExportStatus.exporting,
                    progress: p,
                  ));
                  setSheetState(() {});
                },
              );
            } catch (e) {
              result = ExportState(status: ExportStatus.error, error: '$e');
            }
            if (!mounted || _disposed) return;
            setState(() => _exportState = result);
            setSheetState(() {});
            if (result.status == ExportStatus.success) {
              _message('MP4 export complete: ${result.outputPath}');
            }
          },
        ),
      ),
    );
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  void dispose() {
    _disposed = true;
    _exportService.cancel();
    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _clips.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedAudio = _selectedAudioIndex == null ? null : _audioTracks[_selectedAudioIndex!];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        actions: [
          TextButton(
            onPressed: _showExportSheet,
            child: const Text('Export'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: LayoutBuilder(
                        builder: (context, constraints) => Stack(
                          fit: StackFit.expand,
                          children: [
                            VideoPlayer(controller),
                            ...List.generate(_textOverlays.length, (index) {
                              final overlay = _textOverlays[index];
                              if (!overlay.isVisibleAt(_projectPosition)) {
                                return const SizedBox.shrink();
                              }
                              return Positioned(
                                left: overlay.x * constraints.maxWidth,
                                top: overlay.y * constraints.maxHeight,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedTextIndex = index),
                                  onPanUpdate: (details) => _moveTextOverlay(
                                    index,
                                    details.delta,
                                    constraints.biggest,
                                  ),
                                  child: FractionalTranslation(
                                    translation: const Offset(-0.5, -0.5),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: _selectedTextIndex == index
                                            ? Border.all(color: Colors.white54)
                                            : null,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          overlay.text,
                                          style: TextStyle(
                                            color: overlay.color,
                                            fontSize: overlay.fontSize,
                                            fontWeight: overlay.fontWeight,
                                            shadows: const [
                                              Shadow(blurRadius: 3, color: Colors.black),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _togglePlay,
                    iconSize: 40,
                    icon: Icon(controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  ),
                  Expanded(child: Text('Clip ${_selectedIndex + 1}', overflow: TextOverflow.ellipsis)),
                  Text('${_format(_projectPosition)} / ${_format(_projectDuration)}'),
                ],
              ),
              TimelineEditor(
                clips: _clips,
                selectedIndex: _selectedIndex,
                projectPosition: _projectPosition,
                onScrub: _seekProject,
                onTrimStart: _trimStart,
                onTrimEnd: _trimEnd,
              ),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _addVideos, icon: const Icon(Icons.add), label: const Text('Add Video'))),
                  const SizedBox(width: 6),
                  Expanded(child: FilledButton.icon(onPressed: _splitAtPlayhead, icon: const Icon(Icons.call_split), label: const Text('Split'))),
                  IconButton(onPressed: _deleteSelected, icon: const Icon(Icons.delete_outline)),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 46,
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  itemCount: _clips.length,
                  onReorder: _reorder,
                  itemBuilder: (_, index) {
                    final clip = _clips[index];
                    return Padding(
                      key: ValueKey(clip.id),
                      padding: const EdgeInsets.only(right: 6),
                      child: ReorderableDragStartListener(
                        index: index,
                        child: ChoiceChip(
                          label: Text('☰ Clip ${index + 1}'),
                          selected: index == _selectedIndex,
                          onSelected: (_) => _selectClip(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 18),
              CaptionEditor(
                captions: _captions,
                position: _projectPosition,
                projectDuration: _projectDuration,
                onAdd: _addCaption,
                onDelete: _deleteCaption,
                onSeekCaption: (i) => _seekProject(_captions[i].start),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(onPressed: _createBackup, icon: const Icon(Icons.backup_outlined), label: const Text('Backup')),
                  OutlinedButton.icon(onPressed: _restoreLatestBackup, icon: const Icon(Icons.restore), label: const Text('Restore')),
                  OutlinedButton.icon(onPressed: _clearTempStorage, icon: const Icon(Icons.cleaning_services_outlined), label: const Text('Clean Temp')),
                  OutlinedButton.icon(onPressed: _saveAsTemplate, icon: const Icon(Icons.bookmark_add_outlined), label: const Text('Save Template')),
                  OutlinedButton.icon(onPressed: _showTemplates, icon: const Icon(Icons.auto_awesome_outlined), label: const Text('Templates')),
                ],
              ),
              const Divider(height: 18),
              TextOverlayEditor(
                overlays: _textOverlays,
                selectedIndex: _selectedTextIndex,
                onSelect: (i) => setState(() => _selectedTextIndex = i),
                onAdd: _addTextOverlay,
                onDelete: _deleteSelectedText,
                onTextChanged: (value) {
                  final i = _selectedTextIndex;
                  if (i == null) return;
                  _updateSelectedText(_textOverlays[i].copyWith(text: value));
                },
                onFontSizeChanged: (value) {
                  final i = _selectedTextIndex;
                  if (i == null) return;
                  _updateSelectedText(_textOverlays[i].copyWith(fontSize: value));
                },
                onColorChanged: (value) {
                  final i = _selectedTextIndex;
                  if (i == null) return;
                  _updateSelectedText(_textOverlays[i].copyWith(color: value));
                },
                onBoldChanged: (bold) {
                  final i = _selectedTextIndex;
                  if (i == null) return;
                  _updateSelectedText(_textOverlays[i].copyWith(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  ));
                },
              ),
              const Divider(height: 18),
              AudioTimeline(
                tracks: _audioTracks,
                projectDuration: _projectDuration,
                projectPosition: _projectPosition,
                selectedIndex: _selectedAudioIndex,
                onSelect: (i) => setState(() => _selectedAudioIndex = i),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => _addAudio(background: true), icon: const Icon(Icons.music_note), label: const Text('Music'))),
                  const SizedBox(width: 6),
                  Expanded(child: OutlinedButton.icon(onPressed: () => _addAudio(background: false), icon: const Icon(Icons.audiotrack), label: const Text('Import Audio'))),
                ],
              ),
              if (selectedAudio != null) ...[
                Row(
                  children: [
                    const Text('Volume'),
                    Expanded(
                      child: Slider(
                        value: selectedAudio.volume,
                        onChanged: _setAudioVolume,
                      ),
                    ),
                    Text('${(selectedAudio.volume * 100).round()}%'),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => _trimSelectedAudioStart(const Duration(milliseconds: 250)), child: const Text('Trim Start +'))),
                    const SizedBox(width: 6),
                    Expanded(child: OutlinedButton(onPressed: () => _trimSelectedAudioEnd(const Duration(milliseconds: -250)), child: const Text('Trim End -'))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
