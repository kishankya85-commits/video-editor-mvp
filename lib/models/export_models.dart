enum ExportResolution {
  p480(854, 480, '480p'),
  p720(1280, 720, '720p'),
  p1080(1920, 1080, '1080p');

  final int width;
  final int height;
  final String label;
  const ExportResolution(this.width, this.height, this.label);
}

enum ExportStatus { idle, exporting, success, error, cancelled }

class ExportState {
  final ExportStatus status;
  final double progress;
  final String? outputPath;
  final String? error;

  const ExportState({
    this.status = ExportStatus.idle,
    this.progress = 0,
    this.outputPath,
    this.error,
  });

  ExportState copyWith({
    ExportStatus? status,
    double? progress,
    String? outputPath,
    String? error,
  }) => ExportState(
    status: status ?? this.status,
    progress: progress ?? this.progress,
    outputPath: outputPath ?? this.outputPath,
    error: error,
  );
}
