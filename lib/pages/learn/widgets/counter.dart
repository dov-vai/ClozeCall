import 'package:flutter/material.dart';

class Counter extends StatelessWidget {
  final int correct;
  final int incorrect;

  const Counter({
    required this.correct,
    required this.incorrect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconText(context, Icons.check, correct, Colors.green),
        const SizedBox(width: 16),
        _buildIconText(context, Icons.close, incorrect, Colors.red),
      ],
    );
  }

  Widget _buildIconText(
      BuildContext context, IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
