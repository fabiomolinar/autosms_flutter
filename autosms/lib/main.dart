import 'package:flutter/material.dart';
import 'calendar.dart';
import 'configure_calendar_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Automatic SMS';
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Calendar> _calendars = [];
  final ScrollController _scrollController = ScrollController();

  void _addCalendar() {
    setState(() {
      final newIndex = _calendars.length;
      _calendars.add(Calendar(name: 'Calendar $newIndex'));
    });
    _scrollToBottom();
  }

  void _deleteCalendar(int index) {
    setState(() {
      _calendars.removeAt(index);
    });
  }

  void _confirmDeleteCalendar(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this calendar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                _deleteCalendar(index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _configureCalendar(Calendar calendar) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigureCalendarScreen(
          calendar: calendar,
          onSave: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _calendars.length,
        itemBuilder: (context, index) {
          return CalendarWidget(
            calendar: _calendars[index],
            onDelete: () => _confirmDeleteCalendar(index),
            onConfigure: () => _configureCalendar(_calendars[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCalendar,
        tooltip: 'Add new calendar.',
        child: const Icon(Icons.add),
      ),
    );
  }
}