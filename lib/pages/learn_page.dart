import 'package:cloze_call/services/cloze_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  late ClozeService _clozeService;
  var _cloze = Cloze(original: "", translated: "", answer: "", words: []);
  var _answered = false;

  @override
  void initState() {
    _clozeService = Provider.of<ClozeService>(context, listen: false);
    if (_clozeService.initialized) {
      _cloze = _clozeService.getRandomCloze();
    } else {
      Navigator.pop(context);
    }
    super.initState();
  }

  void onSelected(String selectedWord) async {
    setState(() {
      _answered = true;
    });
  }

  void onNext() {
    setState(() {
      _answered = false;
      _cloze = _clozeService.getRandomCloze();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _answered ? buildAnsweredCloze() : buildCloze(),
        ),
      ),
    );
  }

  List<Widget> buildCloze() {
    return [
      Text(_cloze.original.replaceFirst(_cloze.answer, '_')),
      for (var word in _cloze.words)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            onPressed: () {
              onSelected(word);
            },
            child: Text(word),
          ),
        )
    ];
  }

  List<Widget> buildAnsweredCloze() {
    return [
      Text(_cloze.original),
      for (var word in _cloze.words)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
              onPressed: () {
                onSelected(word);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      word == _cloze.answer ? Colors.green : Colors.red),
              child: Text("$word️")),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: ElevatedButton(
          onPressed: onNext,
          child: const Text("Next ➡️"),
        ),
      )
    ];
  }
}
