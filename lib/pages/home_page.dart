import 'package:cloze_call/services/cloze/cloze_review_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var clozeReviewService =
        Provider.of<ClozeReviewService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloze Call'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/learn');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
              ),
              icon: const Icon(Icons.school),
              label: const Text("Learn"),
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder(
                valueListenable: clozeReviewService.countNotifier,
                builder: (context, count, _) {
                  return ElevatedButton.icon(
                      onPressed: () {
                        if (count != 0) {
                          Navigator.pushNamed(context, '/review');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 64),
                      ),
                      icon: const Icon(Icons.book),
                      label: Text("Review ($count words)"));
                }),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/language');
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64)),
              icon: const Icon(Icons.language),
              label: const Text("Language"),
            ),
          ],
        ),
      )),
    );
  }
}
