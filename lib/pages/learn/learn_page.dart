import 'dart:collection';
import 'dart:math';

import 'package:cloze_call/data/repositories/config_repository.dart';
import 'package:cloze_call/pages/learn/widgets/cloze_question.dart';
import 'package:cloze_call/pages/learn/widgets/counter.dart';
import 'package:cloze_call/pages/learn/widgets/empty.dart';
import 'package:cloze_call/pages/learn/widgets/timer.dart';
import 'package:cloze_call/services/cloze/i_cloze_service.dart';
import 'package:cloze_call/services/tts_service.dart';
import 'package:cloze_call/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

import '../../data/enums/rank.dart';
import '../../data/models/cloze.dart';
import '../../data/models/config.dart';
import '../../services/cloze/cloze_exceptions.dart';
import 'hands_free_options.dart';

class LearnPage extends StatefulWidget {
  final IClozeService clozeService;
  final bool handsFree;
  const LearnPage(
      {super.key, required this.clozeService, this.handsFree = false});

  @override
  State createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final random = Random();
  final translator = GoogleTranslator();
  var currentCloze = Cloze(
      timestamp: DateTime.now().toUtc(),
      original: '',
      translated: '',
      answer: '',
      words: [],
      languageCode: '',
      rank: Rank.zero);
  var answer = '';
  final translatedCache = HashMap<String, String>();
  int correctAnswers = 0;
  int totalAnswers = 0;
  bool clozeServiceEmpty = false;
  bool userExited = false;
  int timeLeft = 0;
  int thinkingSeconds = 20;
  int reviewSeconds = 10;
  late bool handsFreeOptionsConfirmed;
  late ConfigRepository config;
  late TTSService tts;

  @override
  void initState() {
    super.initState();
    tts = Provider.of<TTSService>(context, listen: false);
    config = Provider.of<ConfigRepository>(context, listen: false);

    if (!widget.clozeService.initialized) {
      Navigator.pop(context);
      return;
    }

    config.get('thinking_seconds').then((value) {
      final parsed = int.tryParse(value ?? '');
      if (parsed != null) {
        setState(() {
          thinkingSeconds = parsed;
        });
      }
    });

    config.get('review_seconds').then((value) {
      final parsed = int.tryParse(value ?? '');
      if (parsed != null) {
        setState(() {
          reviewSeconds = parsed;
        });
      }
    });

    currentCloze = getCloze();

    handsFreeOptionsConfirmed = !widget.handsFree;
  }

  @override
  void dispose() {
    userExited = true;
    super.dispose();
  }

  Future<void> wait(int seconds) async {
    for (int i = seconds; i >= 0 && !userExited; i--) {
      setState(() {
        timeLeft = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> handsFreeLoop() async {
    while (!userExited) {
      await wait(thinkingSeconds);
      if (userExited) break;
      onSelected(currentCloze.answer);
      await wait(reviewSeconds);
      if (userExited) break;
      onNext();
    }
  }

  Cloze getCloze() {
    try {
      return widget.clozeService.getRandomCloze();
    } on ClozeServiceException {
      Navigator.pop(context);
    }
    throw Exception("Unreachable");
  }

  Future<void> onSelected(String selectedWord) async {
    if (selectedWord == currentCloze.answer) {
      await widget.clozeService.addForReview(
          currentCloze.copyWith(rank: currentCloze.rank.increment()));
    } else {
      await widget.clozeService
          .addForReview(currentCloze.copyWith(rank: Rank.zero));
    }

    tts.play(currentCloze.original, currentCloze.languageCode);
    setState(() {
      answer = selectedWord;
    });
  }

  Future<void> onNext() async {
    await tts.stop();

    late Cloze cloze;
    try {
      cloze = getCloze();
    } on ClozeServiceEmptyException {
      setState(() {
        clozeServiceEmpty = true;
      });
      return;
    }

    setState(() {
      if (answer == currentCloze.answer) {
        correctAnswers++;
      }
      answer = '';
      totalAnswers++;
      currentCloze = cloze;
    });
  }

  Future<void> onWordTooltip(String word, String languageCode) async {
    if (translatedCache[word] != null) {
      return;
    }

    var translation =
        await translator.translate(word, from: languageCode, to: 'en');
    setState(() {
      translatedCache[word] = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: !handsFreeOptionsConfirmed
                ? handsFreeMode()
                : clozeServiceEmpty
                    ? const EmptyWidget()
                    : quiz()),
      ),
    );
  }

  Widget handsFreeMode() {
    return HandsFreeOptions(
      thinkingSeconds: thinkingSeconds,
      reviewSeconds: reviewSeconds,
      onThinkingChanged: (value) => setState(() => thinkingSeconds = value),
      onReviewChanged: (value) => setState(() => reviewSeconds = value),
      onConfirm: () {
        setState(() => handsFreeOptionsConfirmed = true);
        config.insert(
            Config(key: 'thinking_seconds', value: thinkingSeconds.toString()));
        config.insert(
            Config(key: 'review_seconds', value: reviewSeconds.toString()));
        handsFreeLoop();
      },
    );
  }

  Widget quiz() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!widget.handsFree)
          Counter(
              correct: correctAnswers, incorrect: totalAnswers - correctAnswers)
        else
          TimerWidget(time: timeLeft),
        const SizedBox(height: 32),
        Expanded(
          child: answer.isNotEmpty
              ? answeredCloze()
              : ClozeQuestion(
                  cloze: currentCloze,
                  handsFree: widget.handsFree,
                  answered: answer,
                  onSelected: onSelected,
                ),
        ),
      ],
    );
  }

  // TODO: this also needs refactoring, too big and bulky, hard to read
  Widget answeredCloze() {
    return Column(children: [
      Wrap(alignment: WrapAlignment.center, children: [
        for (var word in currentCloze.original.split(' '))
          Wrap(alignment: WrapAlignment.center, children: [
            // use mouse region as hovering over the tooltip doesn't call onTrigger (hack)
            MouseRegion(
              onEnter: (_) async {
                await onWordTooltip(
                    TextUtils.sanitizeWord(word), currentCloze.languageCode);
              },
              child: Tooltip(
                message: translatedCache[TextUtils.sanitizeWord(word)] ??
                    'Translating...',
                height: 25,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(8.0),
                preferBelow: true,
                textStyle: const TextStyle(
                  color: ThemeMode.system == ThemeMode.light
                      ? Colors.white
                      : Colors.black,
                  fontSize: 18,
                ),
                showDuration: const Duration(seconds: 2),
                waitDuration: const Duration(milliseconds: 200),
                onTriggered: () async {
                  await onWordTooltip(
                      TextUtils.sanitizeWord(word), currentCloze.languageCode);
                },
                child: Text(
                  word,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ),
            const Text('  '),
          ]),
      ]),
      const SizedBox(height: 16),
      Text(currentCloze.translated,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center),
      IconButton(
          onPressed: () async {
            await tts.stop();
            await tts.play(currentCloze.original, currentCloze.languageCode);
          },
          icon: const Icon(Icons.audiotrack)),
      for (var word in currentCloze.words)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  backgroundColor: word == currentCloze.answer
                      ? Colors.green
                      : word == answer
                          ? Colors.red
                          : null),
              child: Text(word.toLowerCase(),
                  style: Theme.of(context).textTheme.titleLarge)),
        ),
      const SizedBox(height: 32),
      if (!widget.handsFree) nextButton()
    ]);
  }

  Widget nextButton() {
    return ElevatedButton(
      onPressed: () async {
        await onNext();
      },
      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 64)),
      child: Text('Next', style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
