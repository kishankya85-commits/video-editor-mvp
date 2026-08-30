import 'package:flutter/material.dart';
import '../models/export_models.dart';

class ExportSheet extends StatelessWidget {
  final ExportResolution resolution;
  final ValueChanged<ExportResolution> onResolutionChanged;
  final ExportState state;
  final VoidCallback onExport;
  final VoidCallback onCancel;

  const ExportSheet({
    super.key,
    required this.resolution,
    required this.onResolutionChanged,
    required this.state,
    required this.onExport,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final exporting = state.status == ExportStatus.exporting;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Text('Export MP4', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (!exporting) IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 8),
          DropdownButtonFormField<ExportResolution>(
            value: resolution,
            decoration: const InputDecoration(labelText: 'Resolution'),
            items: ExportResolution.values.map((r) =>
              DropdownMenuItem(value: r, child: Text('${r.label} (${r.width}×${r.height})')),
            ).toList(),
            onChanged: exporting ? null : (v) { if (v != null) onResolutionChanged(v); },
          ),
          if (exporting) ...[
            const SizedBox(height: 18),
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: 8),
            Text('Exporting... ${(state.progress * 100).round()}%'),
            const SizedBox(height: 8),
            const Text('Keep the app open until processing finishes.', style: TextStyle(fontSize: 12)),
          ],
          if (state.status == ExportStatus.success)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Export complete\n${state.outputPath ?? ''}', textAlign: TextAlign.center),
            ),
          if (state.status == ExportStatus.cancelled)
            const Padding(padding: EdgeInsets.only(top: 16), child: Text('Export cancelled.')),
          if (state.status == ExportStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Export failed. ${state.error ?? 'Unknown error'}', maxLines: 4, overflow: TextOverflow.ellipsis),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: exporting ? onCancel : onExport,
              child: Text(exporting ? 'Cancel Export' : 'Export MP4'),
            ),
          ),
        ]),
      ),
    );
  }
}
