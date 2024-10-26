import 'package:flutter/material.dart';

Future<void> progressDialog(BuildContext context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
            title: Text('Please wait'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Loading language'),
                SizedBox(height: 16),
                LinearProgressIndicator()
              ],
            ));
      });
}
