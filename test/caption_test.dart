import 'package:flutter_test/flutter_test.dart';
import 'package:video_editor_mvp_final/models/caption.dart';
void main(){
  test('caption visibility uses timing boundaries',(){
    const c=Caption(id:'1',text:'Hi',start:Duration(seconds:2),end:Duration(seconds:5));
    expect(c.visibleAt(const Duration(seconds:1)),false);
    expect(c.visibleAt(const Duration(seconds:2)),true);
    expect(c.visibleAt(const Duration(seconds:5)),true);
    expect(c.visibleAt(const Duration(seconds:6)),false);
  });
}
