import 'package:flutter/material.dart';
import '../models/caption.dart';

class CaptionEditor extends StatelessWidget {
  final List<Caption> captions;
  final Duration position;
  final Duration projectDuration;
  final VoidCallback onAdd;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onSeekCaption;
  const CaptionEditor({super.key,required this.captions,required this.position,required this.projectDuration,required this.onAdd,required this.onDelete,required this.onSeekCaption});
  String _t(Duration d) => '${d.inMinutes}:${(d.inSeconds%60).toString().padLeft(2,'0')}';
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const Text('Captions',style:TextStyle(fontWeight:FontWeight.w700)),const Spacer(),IconButton(onPressed:onAdd,icon:const Icon(Icons.closed_caption_add))]),
    if(captions.isEmpty) const Text('No captions yet. Add captions manually at the current playhead.'),
    ...List.generate(captions.length,(i)=>Card(child:ListTile(
      title:Text(captions[i].text), subtitle:Text('${_t(captions[i].start)} – ${_t(captions[i].end)}'),
      onTap:()=>onSeekCaption(i), trailing:IconButton(onPressed:()=>onDelete(i),icon:const Icon(Icons.delete_outline)),
    ))),
  ]);
}
