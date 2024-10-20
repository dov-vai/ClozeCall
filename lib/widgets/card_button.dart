import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final IconData? leftIcon;
  final String title;
  final String? subtitle;
  final IconData? rightIcon;
  final VoidCallback onTap;
  final Color? color;

  const CardButton(
      {super.key,
      this.leftIcon,
      required this.title,
      this.subtitle,
      this.rightIcon,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.hardEdge,
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              if (leftIcon != null) Icon(leftIcon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              if (rightIcon != null) Icon(rightIcon, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
