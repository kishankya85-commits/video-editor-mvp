class AudioTrack {
  final String id;
  final String sourcePath;
  final Duration sourceDuration;
  final Duration start;
  final Duration end;
  final Duration timelineStart;
  final double volume;
  final bool isBackgroundMusic;

  const AudioTrack({
    required this.id,
    required this.sourcePath,
    required this.sourceDuration,
    required this.start,
    required this.end,
    required this.timelineStart,
    required this.volume,
    required this.isBackgroundMusic,
  });

  Duration get duration => end - start;

  AudioTrack copyWith({
    Duration? start,
    Duration? end,
    Duration? timelineStart,
    double? volume,
  }) {
    return AudioTrack(
      id: id,
      sourcePath: sourcePath,
      sourceDuration: sourceDuration,
      start: start ?? this.start,
      end: end ?? this.end,
      timelineStart: timelineStart ?? this.timelineStart,
      volume: volume ?? this.volume,
      isBackgroundMusic: isBackgroundMusic,
    );
  }
}
