import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int time;

  const TimerWidget({
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$time",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
