import 'package:cloze_call/widgets/card_button.dart';
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
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          child: CardButton(
            title: "Let's go!",
            onTap: onConfirm,
            rightIcon: Icons.chevron_right,
          ),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, String label, int value,
      void Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        NumberSelect(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
