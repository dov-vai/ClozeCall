import 'package:cloze_call/pages/learn/widgets/translatable_word.dart';
import 'package:cloze_call/widgets/card_button.dart';
import 'package:flutter/material.dart';

import '../../../data/models/cloze.dart';
import '../../../utils/app_colors.dart';

class AnsweredCloze extends StatelessWidget {
  final Cloze currentCloze;
  final Function() onNext;
  final Function() ttsStop;
  final Function(String, String) ttsPlay;
  final bool handsFree;
  final String? answer;

  const AnsweredCloze(
      {super.key,
      required this.currentCloze,
      required this.onNext,
      required this.ttsStop,
      required this.ttsPlay,
      required this.handsFree,
      this.answer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            for (var word in currentCloze.original.split(' '))
              TranslatableWord(
                  word: word, languageCode: currentCloze.languageCode),
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
