import 'package:cloze_call/utils/app_colors.dart';
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
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildRatioBar(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIconText(context, Icons.check, correct, AppColors.green),
            const SizedBox(width: 16),
            _buildIconText(context, Icons.close, incorrect, AppColors.red),
          ],
        )
      ],
    );
  }

  Widget _buildRatioBar() {
    int total = correct + incorrect;
    double correctRatio = total > 0 ? correct / total : 0;
    double incorrectRatio = total > 0 ? incorrect / total : 0;

    const height = 8.0;
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Container(
            height: height,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Positioned(
            left: 0,
            child: Container(
              height: height,
              width: constraints.maxWidth * correctRatio,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: correctRatio == 1.0
                    ? BorderRadius.circular(8)
                    : const BorderRadius.horizontal(left: Radius.circular(8)),
              ),
            ),
          ),
          Positioned(
            left: constraints.maxWidth * correctRatio,
            child: Container(
              height: height,
              width: constraints.maxWidth * incorrectRatio,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: incorrectRatio == 1.0
                    ? BorderRadius.circular(8)
                    : const BorderRadius.horizontal(right: Radius.circular(8)),
              ),
            ),
          ),
        ],
      );
    });
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
