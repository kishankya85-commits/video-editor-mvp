class ProjectTemplate {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<String> clipPaths;
  final List<Map<String, dynamic>> textOverlays;
  final List<Map<String, dynamic>> captions;

  const ProjectTemplate({
    required this.id, required this.name, required this.description,
    required this.createdAt, required this.clipPaths,
    required this.textOverlays, required this.captions,
  });

  Map<String,dynamic> toJson()=> {
    'id':id,'name':name,'description':description,
    'createdAt':createdAt.toIso8601String(),'clipPaths':clipPaths,
    'textOverlays':textOverlays,'captions':captions,
  };

  factory ProjectTemplate.fromJson(Map<String,dynamic> j)=>ProjectTemplate(
    id:j['id'] as String, name:j['name'] as String? ?? 'Untitled template',
    description:j['description'] as String? ?? '',
    createdAt:DateTime.parse(j['createdAt'] as String),
    clipPaths:List<String>.from(j['clipPaths'] ?? const []),
    textOverlays:List<Map<String,dynamic>>.from((j['textOverlays'] ?? const []).map((e)=>Map<String,dynamic>.from(e))),
    captions:List<Map<String,dynamic>>.from((j['captions'] ?? const []).map((e)=>Map<String,dynamic>.from(e))),
  );
}
