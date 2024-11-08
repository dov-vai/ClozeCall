import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int totalClozes;
  final double level;
  final int clozesToNextLevel;

  const StatsCard(
      {required this.totalClozes,
      required this.level,
      required this.clozesToNextLevel,
      super.key});

  @override
  Widget build(BuildContext context) {
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isHorizontal = constraints.maxWidth > 280;

                return Flex(
                  direction: isHorizontal ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    statsPart(
                        Icons.numbers, totalClozes.toString(), 'Total Clozes'),
                    const SizedBox(
                      height: 8,
                    ),
                    levelProgress(
                        "Level ${level.floor()}",
                        "Next: $clozesToNextLevel Clozes",
                        level - level.floor())
                  ],
                );
              },
            ),
          )),
    );
  }

  Widget levelProgress(String title, String subtitle, double progress) {
    return Column(
      children: [
        Row(
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 8.0,
              backgroundColor: Colors.grey[400],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  Widget statsPart(IconData icon, String title, String subtitle) {
    return Column(
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
              mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
