import 'package:flutter/material.dart';
import 'calendar.dart';

class CalendarWidget extends StatelessWidget {
  final Calendar calendar;
  final VoidCallback onDelete;
  final VoidCallback onConfigure;

  const CalendarWidget({
    super.key,
    required this.calendar,
    required this.onDelete,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              calendar.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Configure calendar',
                  onPressed: onConfigure,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  tooltip: 'Send SMS',
                  onPressed: () {
                    // Implement send SMS functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.inbox),
                  tooltip: 'Receive SMS',
                  onPressed: () {
                    // Implement receive SMS functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete calendar',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}