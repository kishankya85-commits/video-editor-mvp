import 'package:flutter/material.dart';
import '../models/audio_track.dart';

class AudioTimeline extends StatelessWidget {
  final List<AudioTrack> tracks;
  final Duration projectDuration;
  final Duration projectPosition;
  final ValueChanged<int> onSelect;
  final int? selectedIndex;

  const AudioTimeline({
    super.key,
    required this.tracks,
    required this.projectDuration,
    required this.projectPosition,
    required this.onSelect,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final totalMs = projectDuration.inMilliseconds <= 0
        ? 1
        : projectDuration.inMilliseconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audio Timeline',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 54,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF171B24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  for (var i = 0; i < tracks.length; i++)
                    _trackBlock(
                      tracks[i],
                      i,
                      constraints.maxWidth,
                      totalMs,
                    ),
                  Positioned(
                    left: ((projectPosition.inMilliseconds / totalMs) *
                                constraints.maxWidth -
                            1)
                        .clamp(0.0, constraints.maxWidth - 2),
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.redAccent),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _trackBlock(
    AudioTrack track,
    int index,
    double width,
    int totalMs,
  ) {
    final left =
        width * track.timelineStart.inMilliseconds / totalMs;
    final blockWidth =
        width * track.duration.inMilliseconds / totalMs;

    return Positioned(
      left: left,
      top: 7 + (index % 2) * 2,
      width: blockWidth.clamp(30.0, width),
      height: 40,
      child: InkWell(
        onTap: () => onSelect(index),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selectedIndex == index
                  ? Colors.white
                  : const Color(0xFF7E57C2),
              width: selectedIndex == index ? 2 : 1,
            ),
            color: const Color(0xFF2A2140),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            track.isBackgroundMusic ? 'Music' : 'Audio',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}
