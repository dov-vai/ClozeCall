import 'package:cloze_call/data/streams/cloze_stream_service.dart';
import 'package:cloze_call/widgets/card_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/cloze/cloze_review_service.dart';
import '../../services/cloze/cloze_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ClozeReviewService clozeReviewService;
  late final ClozeService clozeService;
  late final ClozeStreamService clozeStreamService;
  int totalClozes = 0;

  @override
  void initState() {
    super.initState();

    clozeReviewService =
        Provider.of<ClozeReviewService>(context, listen: false);
    clozeService = Provider.of<ClozeService>(context, listen: false);
    clozeStreamService =
        Provider.of<ClozeStreamService>(context, listen: false);

    setupStats();
    showInitDialog();
  }

  void setupStats() {
    clozeStreamService.count.listen((count) {
      setState(() {
        totalClozes = count;
      });
    });
  }

  Future<void> showInitDialog() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!clozeService.initialized) {
        await uninitializedDialog(clozeService);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Cloze Call"),
        ),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          // TODO: more stats
                          statsCard(totalClozes),
                          const SizedBox(
                            height: 32,
                          ),
                          const Text("Practice makes perfect"),
                          ValueListenableBuilder(
                              valueListenable: clozeReviewService.countNotifier,
                              builder: (context, count, _) {
                                return CardButton(
                                    leftIcon: Icons.book,
                                    title: "Review",
                                    subtitle: "$count words to review",
                                    rightIcon: Icons.chevron_right,
                                    onTap: () {
                                      if (count != 0) {
                                        Navigator.pushNamed(context, '/review');
                                      }
                                    });
                              }),
                          const SizedBox(
                            height: 32,
                          ),
                          const Text("Ready for new clozes?"),
                          CardButton(
                              leftIcon: Icons.school,
                              title: "Learn",
                              subtitle: "Classic mode with 4 answers",
                              rightIcon: Icons.chevron_right,
                              onTap: () {
                                Navigator.pushNamed(context, '/learn');
                              }),
                          CardButton(
                              leftIcon: Icons.headphones,
                              title: "Hands-Free",
                              subtitle: "Relax from tapping",
                              rightIcon: Icons.chevron_right,
                              onTap: () {
                                Navigator.pushNamed(context, '/handsfree');
                              }),
                          const SizedBox(
                            height: 32,
                          ),
                          const Text("Try a different language"),
                          CardButton(
                              leftIcon: Icons.language,
                              title: "Language",
                              subtitle: "Pick a language to study",
                              rightIcon: Icons.chevron_right,
                              onTap: () {
                                Navigator.pushNamed(context, '/language');
                              })
                        ],
                      ),
                    ),
                  ],
                ))));
  }

  Widget statsCard(int total) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xffD38312), Color(0xffA83279)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                statsPart(Icons.numbers, total.toString(), 'Total Clozes'),
              ],
            ),
          )),
    );
  }

  Widget statsPart(IconData icon, String title, String subtitle) {
    return Expanded(
        child: Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                )
              ],
            )
          ],
        )
      ],
    ));
  }

  Future<void> uninitializedDialog(ClozeService service) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              title: const Text("Language file not found"),
              content: const Text("Please select a language file."),
              actions: <Widget>[
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/language');
                    },
                    child: const Text("On it!"))
              ]);
        });
  }
}
