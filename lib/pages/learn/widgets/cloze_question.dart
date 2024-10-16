import 'package:flutter/material.dart';

import '../../../data/models/cloze.dart';

class ClozeQuestion extends StatelessWidget {
  final Cloze cloze;
  final bool handsFree;
  final String answered;
  final void Function(String) onSelected;

  const ClozeQuestion({
    required this.cloze,
    required this.handsFree,
    required this.answered,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          cloze.original.replaceFirst(cloze.answer, '_____'),
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          cloze.translated,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        for (var word in cloze.words)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: !handsFree ? () => onSelected(word) : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
              ),
              child: Text(word.toLowerCase(),
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          )
      ],
    );
  }
}
