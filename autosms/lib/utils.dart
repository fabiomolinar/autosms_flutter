import 'package:flutter/material.dart';

class SimpleDialog extends StatelessWidget {
  final String message;

  const SimpleDialog({Key? key, required this.message}) : super(key: key);

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