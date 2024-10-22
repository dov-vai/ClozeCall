import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int time;
  final int totalTime;

  const TimerWidget({
    required this.time,
    required this.totalTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        _buildTimerBar(),
        const SizedBox(height: 8),
        Text(
          "$time",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTimerBar() {
    double timeRatio = totalTime > 0 ? time / totalTime : 0;

    const height = 8.0;
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(children: [
        Container(
          height: height,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Container(
          height: height,
          width: constraints.maxWidth * timeRatio,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8)),
        ),
      ]);
    });
  }
}
