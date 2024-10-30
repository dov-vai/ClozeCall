import 'package:flutter/material.dart';

class NetworkErrorWidget extends StatelessWidget {
  final String description;

  const NetworkErrorWidget({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.signal_wifi_bad,
          size: 100,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        const SizedBox(height: 20),
        const Text(
          "Network Error",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
