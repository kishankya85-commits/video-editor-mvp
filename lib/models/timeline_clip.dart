class TimelineClip {
  final String id;
  final String sourcePath;
  final Duration sourceDuration;
  final Duration start;
  final Duration end;

  const TimelineClip({
    required this.id,
    required this.sourcePath,
    required this.sourceDuration,
    required this.start,
    required this.end,
  });

  Duration get duration => end - start;

  TimelineClip copyWith({
    Duration? start,
    Duration? end,
  }) {
    return TimelineClip(
      id: id,
      sourcePath: sourcePath,
      sourceDuration: sourceDuration,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
