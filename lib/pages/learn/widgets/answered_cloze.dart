import 'dart:collection';

import 'package:cloze_call/utils/text_utils.dart';
import 'package:cloze_call/widgets/card_button.dart';
import 'package:flutter/material.dart';

import '../../../data/models/cloze.dart';
import '../../../utils/app_colors.dart';

class AnsweredCloze extends StatelessWidget {
  final Cloze currentCloze;
  final Function(String) onWordTooltip;
  final Function() onNext;
  final Function() ttsStop;
  final Function(String, String) ttsPlay;
  final bool handsFree;
  final String? answer;
  final HashMap<String, String> translationCache;

  const AnsweredCloze(
      {super.key,
      required this.currentCloze,
      required this.onWordTooltip,
      required this.onNext,
      required this.ttsStop,
      required this.ttsPlay,
      required this.handsFree,
      this.answer,
      required this.translationCache});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (var word in currentCloze.original.split(' '))
              buildTranslatableWord(word, context),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          currentCloze.translated,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        IconButton(
          onPressed: () async {
            await ttsStop();
            await ttsPlay(currentCloze.original, currentCloze.languageCode);
          },
          icon: const Icon(Icons.audiotrack),
        ),
        for (var word in currentCloze.words) buildAnswerButton(word, context),
        const SizedBox(height: 24),
        if (!handsFree) nextButton(context),
      ],
    );
  }

  Widget buildTranslatableWord(String word, BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        MouseRegion(
          onEnter: (_) async {
            await onWordTooltip(word);
          },
          child: Tooltip(
            message: translationCache[TextUtils.sanitizeWord(word)] ??
                'Translating...',
            height: 25,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              word,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ),
        const Text('  '),
      ],
    );
  }

  Widget buildAnswerButton(String word, BuildContext context) {
    Color? backgroundColor = word == currentCloze.answer
        ? AppColors.green
        : word == answer
            ? AppColors.red
            : null;

    IconData? rightIcon = word == currentCloze.answer
        ? Icons.check
        : word == answer
            ? Icons.close
            : null;

    return CardButton(
      title: word,
      onTap: () {},
      color: backgroundColor,
      rightIcon: rightIcon,
    );
  }

  Widget nextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await onNext();
      },
      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 64)),
      child: Text('Next', style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
