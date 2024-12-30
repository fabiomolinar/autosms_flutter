import 'package:flutter/material.dart';

class MySimpleDialog extends StatelessWidget {
  final String message;

  const MySimpleDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Information'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); 
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}