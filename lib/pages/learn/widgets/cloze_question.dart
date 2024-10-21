import 'package:cloze_call/widgets/card_button.dart';
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
          style: Theme.of(context).textTheme.headlineMedium,
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
          CardButton(
              title: word.toLowerCase(),
              rightIcon: Icons.chevron_right,
              onTap: !handsFree ? () => onSelected(word) : () {})
      ],
    );
  }
}
