import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Google Calendar Events';
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
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _confirmationTextController = TextEditingController();
  final _appendTextController = TextEditingController();

  static const _scopes = [google_calendar.CalendarApi.calendarScope];

  google_calendar.CalendarApi? _calendarApi;

  Future<void> _authenticateWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: _scopes);
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return;
    }

    final googleAuth = await googleUser.authentication;     
    final client = authenticatedClient(http.Client(), AccessCredentials(
      AccessToken('Bearer', googleAuth.accessToken!, DateTime.now().add(Duration(seconds: googleAuth.expiresIn!))),
      googleAuth.refreshToken!,
      _scopes,
    ));

    setState(() {
      _calendarApi = google_calendar.CalendarApi(client);
    });
    _showCalendarList();
  }

  Future<void> _showCalendarList() async {
    if (_calendarApi == null) return;

    final calendars = await _calendarApi!.calendarList.list();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Calendar'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: calendars.items?.length ?? 0,
              itemBuilder: (context, index) {
                final calendar = calendars.items![index];
                return ListTile(
                  title: Text(calendar.summary ?? 'Unnamed Calendar'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEventsForNextDay(calendar.id!);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEventsForNextDay(String calendarId) async {
    if (_calendarApi == null) return;

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final events = await _calendarApi!.events.list(
      calendarId,
      timeMin: tomorrow,
      timeMax: tomorrow.add(const Duration(days: 1)),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Events for Tomorrow'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: events.items?.length ?? 0,
              itemBuilder: (context, index) {
                final event = events.items![index];
                return ListTile(
                  title: Text(event.summary ?? 'Unnamed Event'),
                  subtitle: Text(event.start?.dateTime?.toString() ?? 'No start time'),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmationTextController,
                decoration: const InputDecoration(labelText: 'Confirmation Text'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter confirmation text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _appendTextController,
                decoration: const InputDecoration(labelText: 'Text to Append'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter text to append';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticateWithGoogle,
                child: const Text('Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}