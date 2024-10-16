import 'package:flutter/material.dart';

import 'widgets/number_select.dart';

class HandsFreeOptions extends StatelessWidget {
  final int thinkingSeconds;
  final int reviewSeconds;
  final void Function(int) onThinkingChanged;
  final void Function(int) onReviewChanged;
  final VoidCallback onConfirm;

  const HandsFreeOptions({
    required this.thinkingSeconds,
    required this.reviewSeconds,
    required this.onThinkingChanged,
    required this.onReviewChanged,
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Hands-free options",
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 32),
        _buildOption(
          context,
          "Thinking time (seconds)",
          thinkingSeconds,
          onThinkingChanged,
        ),
        const SizedBox(height: 32),
        _buildOption(
          context,
          "Review time (seconds)",
          reviewSeconds,
          onReviewChanged,
        ),
        const SizedBox(height: 64),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 64)),
          child: const Text("Let's go!"),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, String label, int value,
      void Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        NumberSelect(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
