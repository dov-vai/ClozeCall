import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TranslatableWord extends StatefulWidget {
  final String word;
  final String languageCode;
  const TranslatableWord(
      {super.key, required this.word, required this.languageCode});

  @override
  State<TranslatableWord> createState() => _TranslatableWordState();
}

class _TranslatableWordState extends State<TranslatableWord> {
  final translator = GoogleTranslator();
  String? translated;

  Future<void> onWordTooltip(String word, String languageCode) async {
    if (translated != null) {
      return;
    }

    var translation =
        await translator.translate(word, from: languageCode, to: 'en');
    setState(() {
      translated = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        MouseRegion(
          onEnter: (_) async {
            await onWordTooltip(widget.word, widget.languageCode);
          },
          child: Tooltip(
            message: translated ?? 'Translating...',
            height: 25,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8.0),
            triggerMode: TooltipTriggerMode.tap,
            onTriggered: () async {
              await onWordTooltip(widget.word, widget.languageCode);
            },
            child: Text(
              widget.word,
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
}
