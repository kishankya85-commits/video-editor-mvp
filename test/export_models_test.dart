import 'package:flutter_test/flutter_test.dart';
import 'package:video_editor_mvp_final/models/export_models.dart';

void main() {
  test('export resolutions expose required dimensions', () {
    expect(ExportResolution.p480.width, 854);
    expect(ExportResolution.p720.height, 720);
    expect(ExportResolution.p1080.width, 1920);
  });

  test('export state copyWith updates progress', () {
    const state = ExportState(status: ExportStatus.exporting, progress: .25);
    final next = state.copyWith(progress: .75);
    expect(next.status, ExportStatus.exporting);
    expect(next.progress, .75);
  });
}
