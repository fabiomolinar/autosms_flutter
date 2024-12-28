import 'package:flutter/material.dart';
import 'configure_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<CalendarWidget> _calendars = [];

  void _addCalendar() {
    setState(() {
      _calendars.add(CalendarWidget());
    });
  }

  void _deleteCalendar(int index) {
    setState(() {
      _calendars.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Widgets'),
      ),
      body: ListView.builder(
        itemCount: _calendars.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(_calendars[index].toString()),
            onDismissed: (direction) {
              _deleteCalendar(index);
            },
            background: Container(color: Colors.red),
            child: _calendars[index],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCalendar,
        child: Icon(Icons.add),
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Calendar Title'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfigurePage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                // Start send SMS task
              },
            ),
            IconButton(
              icon: Icon(Icons.message),
              onPressed: () {
                // Start read SMS task
              },
            ),
          ],
        ),
      ),
    );
  }
}