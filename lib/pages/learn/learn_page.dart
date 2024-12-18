import 'dart:async';
import 'dart:math';

import 'package:cloze_call/data/repositories/config_repository.dart';
import 'package:cloze_call/pages/learn/widgets/answered_cloze.dart';
import 'package:cloze_call/pages/learn/widgets/cloze_question.dart';
import 'package:cloze_call/pages/learn/widgets/counter.dart';
import 'package:cloze_call/pages/learn/widgets/empty.dart';
import 'package:cloze_call/pages/learn/widgets/timer.dart';
import 'package:cloze_call/services/cloze/i_cloze_service.dart';
import 'package:cloze_call/services/connectivity_service.dart';
import 'package:cloze_call/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  var currentCloze = Cloze(
      timestamp: DateTime.now().toUtc(),
      original: '',
      translated: '',
      answer: '',
      words: [],
      languageCode: '',
      rank: Rank.zero);
  var answer = '';
  int correctAnswers = 0;
  int totalAnswers = 0;
  bool clozeServiceEmpty = false;
  bool userExited = false;
  bool connected = false;
  int timeLeft = 0;
  int timeSet = 0;
  int thinkingSeconds = 20;
  int reviewSeconds = 10;
  late bool handsFreeOptionsConfirmed;
  late ConfigRepository config;
  late TTSService tts;
  late ConnectivityService connectivity;
  late StreamSubscription connStream;

  @override
  void initState() {
    super.initState();
    tts = Provider.of<TTSService>(context, listen: false);
    config = Provider.of<ConfigRepository>(context, listen: false);
    connectivity = Provider.of<ConnectivityService>(context, listen: false);

    if (!widget.clozeService.initialized) {
      Navigator.pop(context);
      return;
    }

    connStream =
        connectivity.onConnectivityChanged.listen(onConnectivityChanged);
    initializeConfig();
    currentCloze = getCloze();
    handsFreeOptionsConfirmed = !widget.handsFree;
  }

  Future<void> onConnectivityChanged(bool connected) async {
    // in case the user enters learning while offline,
    if (connected) {
      await tts.initialize();
    }

    setState(() {
      this.connected = connected;
    });
  }

  Future<void> initializeConfig() async {
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
  }

  @override
  void dispose() {
    userExited = true;
    connStream.cancel();
    super.dispose();
  }

  Future<void> wait(int seconds) async {
    setState(() {
      timeSet = seconds;
    });

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
    final updatedRank = selectedWord == currentCloze.answer
        ? currentCloze.rank.increment()
        : Rank.zero;

    await widget.clozeService
        .addForReview(currentCloze.copyWith(rank: updatedRank));

    if (connected) {
      tts.play(currentCloze.original, currentCloze.languageCode);
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!connected)
            const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.signal_wifi_bad))
        ],
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
          TimerWidget(time: timeLeft, totalTime: timeSet),
        const SizedBox(height: 32),
        Expanded(
            child: ListView(
          children: [
            answer.isNotEmpty
                ? AnsweredCloze(
                    currentCloze: currentCloze,
                    onNext: onNext,
                    ttsStop: () => tts.stop(),
                    ttsPlay: (text, lang) => tts.play(text, lang),
                    handsFree: widget.handsFree,
                    connected: connected,
                    answer: answer,
                  )
                : ClozeQuestion(
                    cloze: currentCloze,
                    handsFree: widget.handsFree,
                    answered: answer,
                    onSelected: onSelected,
                  ),
          ],
        ))
      ],
    );
  }
}
