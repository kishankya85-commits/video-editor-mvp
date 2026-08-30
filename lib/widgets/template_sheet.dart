import 'package:flutter/material.dart';
import '../models/project_template.dart';

class TemplateSheet extends StatelessWidget {
  final List<ProjectTemplate> templates;
  final ValueChanged<ProjectTemplate> onApply;
  final ValueChanged<ProjectTemplate> onDelete;
  const TemplateSheet({super.key,required this.templates,required this.onApply,required this.onDelete});

  @override Widget build(BuildContext context)=>SafeArea(child:Padding(
    padding:const EdgeInsets.all(20),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Row(children:[const Text('My Templates',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const Spacer(),IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))]),
      if(templates.isEmpty) const Padding(padding:EdgeInsets.all(24),child:Text('No saved templates yet. Save the current project as a template.')),
      Flexible(child:ListView.builder(shrinkWrap:true,itemCount:templates.length,itemBuilder:(c,i){
        final t=templates[i];
        return Card(child:ListTile(
          leading:const Icon(Icons.auto_awesome_outlined),
          title:Text(t.name),subtitle:Text(t.description),
          onTap:()=>onApply(t),
          trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()=>onDelete(t)),
        ));
      })),
    ]),
  ));
}
