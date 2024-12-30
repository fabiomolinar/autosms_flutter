import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'calendar/google_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Automated SMS';
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
  // Form attributes
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _confirmationTextController = TextEditingController();
  final _appendTextController = TextEditingController();

  // Form text validator
  String? _formTextValidator(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  // Form on pressed
  void _formOnPressed(String calendarType) {
    if (_formKey.currentState!.validate()) {
      print('Form is valid');
      if (calendarType == 'google') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleCalendar(messageTemplate: _messageController.text),
          ),
        );        
      } else if (calendarType == 'outlook') {
        // Outlook Calendar
        print('Outlook Calendar');
      }
    } else {
      print('Form is invalid');
    }
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
                validator: (value) => _formTextValidator(value, 'Please enter a message. Use "[day]" and "[hour]" symbols to add dynamic text to the message.'),
              ),
              TextFormField(
                controller: _confirmationTextController,
                decoration: const InputDecoration(labelText: 'Confirmation Text'),
                validator: (value) => _formTextValidator(value, 'Please enter confirmation text'),
              ),
              TextFormField(
                controller: _appendTextController,
                decoration: const InputDecoration(labelText: 'Text to Append'),
                validator: (value) => _formTextValidator(value, 'Please enter text to append to event'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _formOnPressed('google'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FontAwesomeIcons.google),
                    const Text('   Google'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _formOnPressed('outlook'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FontAwesomeIcons.microsoft),
                    const Text('   Outlook'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}