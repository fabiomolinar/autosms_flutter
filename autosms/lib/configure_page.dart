import 'package:flutter/material.dart';

class ConfigurePage extends StatelessWidget {
  const ConfigurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'SMS Text Message'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Expected Confirmation Message'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Confirmation Text for Event Title'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save configuration
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}