import 'package:flutter/material.dart';

class NumberSelect extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const NumberSelect({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: IconButton.filled(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (value > 0) onChanged(value - 1);
              },
            )),
        SizedBox(
          width: 120,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: value.toString()),
            onChanged: (val) => onChanged(int.tryParse(val) ?? 0),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(16),
            child: IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: () => onChanged(value + 1),
            ))
      ],
    );
  }
}
