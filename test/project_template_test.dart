import 'package:flutter_test/flutter_test.dart';
import 'package:video_editor_mvp_final/models/project_template.dart';
void main(){
 test('template JSON round trip',(){
  final t=ProjectTemplate(id:'1',name:'Test',description:'Demo',createdAt:DateTime(2026,1,1),clipPaths:['a.mp4'],textOverlays:const [],captions:const []);
  final r=ProjectTemplate.fromJson(t.toJson());
  expect(r.name,'Test'); expect(r.clipPaths.single,'a.mp4');
 });
}
