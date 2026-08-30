import 'package:flutter/material.dart';
import '../models/timeline_clip.dart';

class TimelineEditor extends StatelessWidget {
  final List<TimelineClip> clips;
  final int selectedIndex;
  final Duration projectPosition;
  final ValueChanged<Duration> onScrub;
  final ValueChanged<Duration> onTrimStart;
  final ValueChanged<Duration> onTrimEnd;

  const TimelineEditor({
    super.key,
    required this.clips,
    required this.selectedIndex,
    required this.projectPosition,
    required this.onScrub,
    required this.onTrimStart,
    required this.onTrimEnd,
  });

  Duration get _totalDuration => clips.fold(
        Duration.zero,
        (sum, clip) => sum + clip.duration,
      );

  Duration _projectStartFor(int index) => clips
      .take(index)
      .fold(Duration.zero, (sum, clip) => sum + clip.duration);

  @override
  Widget build(BuildContext context) {
    final total = _totalDuration;
    final totalMs = total.inMilliseconds <= 0 ? 1 : total.inMilliseconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${_format(projectPosition)} / ${_format(total)}',
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final playheadX = width *
                (projectPosition.inMilliseconds.clamp(0, totalMs) / totalMs);

            return SizedBox(
              height: 112,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 20,
                    height: 72,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) => _scrub(
                        details.localPosition.dx,
                        width,
                        totalMs,
                      ),
                      onHorizontalDragUpdate: (details) => _scrub(
                        details.localPosition.dx,
                        width,
                        totalMs,
                      ),
                      child: Row(
                        children: List.generate(clips.length, (index) {
                          final clip = clips[index];
                          final clipWidth = width *
                              (clip.duration.inMilliseconds / totalMs);
                          final selected = index == selectedIndex;

                          return SizedBox(
                            width: clipWidth,
                            child: Container(
                              margin: EdgeInsets.only(
                                right: index == clips.length - 1 ? 0 : 3,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF3D5AFE)
                                    : const Color(0xFF2A3140),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? Colors.white70
                                      : const Color(0xFF4A5264),
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Row(
                                    children: List.generate(
                                      6,
                                      (i) => Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 1,
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              i.isEven ? .13 : .07,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'CLIP ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  if (selectedIndex >= 0 && selectedIndex < clips.length)
                    ..._selectedHandles(width, totalMs),
                  Positioned(
                    left: (playheadX - 1).clamp(0.0, width - 2),
                    top: 0,
                    bottom: 8,
                    child: Container(width: 2, color: Colors.redAccent),
                  ),
                  Positioned(
                    left: (playheadX - 7).clamp(0.0, width - 14),
                    top: 0,
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0:00', style: TextStyle(color: Colors.white60)),
            Text(
              '${clips.length} clip${clips.length == 1 ? '' : 's'}',
              style: const TextStyle(color: Colors.white60),
            ),
            Text(
              _format(total),
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _selectedHandles(double width, int totalMs) {
    final clip = clips[selectedIndex];
    final startProject = _projectStartFor(selectedIndex);
    final startX = width * startProject.inMilliseconds / totalMs;
    final endX = width *
        (startProject.inMilliseconds + clip.duration.inMilliseconds) /
        totalMs;

    return [
      Positioned(
        left: (startX - 10).clamp(0.0, width - 20),
        top: 25,
        child: _TrimHandle(
          onDrag: (dx) => onTrimStart(
            Duration(
              milliseconds: (dx * totalMs / width).round(),
            ),
          ),
        ),
      ),
      Positioned(
        left: (endX - 10).clamp(0.0, width - 20),
        top: 25,
        child: _TrimHandle(
          onDrag: (dx) => onTrimEnd(
            Duration(
              milliseconds: (dx * totalMs / width).round(),
            ),
          ),
        ),
      ),
    ];
  }

  void _scrub(double dx, double width, int totalMs) {
    final ratio = (dx / width).clamp(0.0, 1.0);
    onScrub(Duration(milliseconds: (totalMs * ratio).round()));
  }

  String _format(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _TrimHandle extends StatelessWidget {
  final ValueChanged<double> onDrag;

  const _TrimHandle({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
      child: Container(
        width: 20,
        height: 62,
        decoration: BoxDecoration(
          color: const Color(0xFFFFC857),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.drag_indicator,
          size: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}
