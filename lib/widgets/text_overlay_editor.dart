import 'package:flutter/material.dart';
import '../models/text_overlay.dart';

class TextOverlayEditor extends StatelessWidget {
  final List<TextOverlay> overlays;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final VoidCallback onDelete;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<bool> onBoldChanged;

  const TextOverlayEditor({
    super.key,
    required this.overlays,
    required this.selectedIndex,
    required this.onSelect,
    required this.onAdd,
    required this.onDelete,
    required this.onTextChanged,
    required this.onFontSizeChanged,
    required this.onColorChanged,
    required this.onBoldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == null ? null : overlays[selectedIndex!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Text Overlay', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              tooltip: 'Add text',
              onPressed: onAdd,
              icon: const Icon(Icons.text_fields),
            ),
            if (selected != null)
              IconButton(
                tooltip: 'Delete text',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: overlays.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, index) => ChoiceChip(
              label: Text(overlays[index].text.isEmpty
                  ? 'Text ${index + 1}'
                  : overlays[index].text),
              selected: index == selectedIndex,
              onSelected: (_) => onSelect(index),
            ),
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: selected.text,
                selection: TextSelection.collapsed(offset: selected.text.length),
              ),
            ),
            onChanged: onTextChanged,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              labelText: 'Text',
            ),
          ),
          Row(
            children: [
              const Text('Size'),
              Expanded(
                child: Slider(
                  min: 12,
                  max: 72,
                  value: selected.fontSize,
                  onChanged: onFontSizeChanged,
                ),
              ),
              SizedBox(
                width: 34,
                child: Text('${selected.fontSize.round()}'),
              ),
              IconButton(
                onPressed: () => onBoldChanged(selected.fontWeight != FontWeight.bold),
                icon: Icon(
                  Icons.format_bold,
                  color: selected.fontWeight == FontWeight.bold ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              _colorButton(Colors.white),
              _colorButton(Colors.redAccent),
              _colorButton(Colors.amber),
              _colorButton(Colors.lightBlueAccent),
              _colorButton(Colors.lightGreenAccent),
            ],
          ),
        ],
      ],
    );
  }

  Widget _colorButton(Color color) {
    return InkWell(
      onTap: () => onColorChanged(color),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54),
        ),
      ),
    );
  }
}
