import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar/google_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'AutoSMS';
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
  final _declineTextController = TextEditingController();
  final _appendConfirmedTextController = TextEditingController();
  final _appendSentTextController = TextEditingController();
  final _appendDeclinedTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _messageController.text = prefs.getString('message') ?? '';
      _confirmationTextController.text = prefs.getString('confirmationText') ?? 'TAK';
      _declineTextController.text = prefs.getString('declineText') ?? 'NIE';
      _appendConfirmedTextController.text = prefs.getString('appendConfirmed') ?? '[Potw.]';
      _appendSentTextController.text = prefs.getString('appendSent') ?? '[Wysy.]';
      _appendDeclinedTextController.text = prefs.getString('appendDeclined') ?? '[Odrz.]';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('message', _messageController.text);
    prefs.setString('confirmationText', _confirmationTextController.text);
    prefs.setString('declineText', _declineTextController.text);
    prefs.setString('appendConfirmed', _appendConfirmedTextController.text);        
    prefs.setString('appendSent', _appendSentTextController.text);
    prefs.setString('appendDeclined', _appendDeclinedTextController.text);
  }

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
      // Save configuration to shared preferences
      _savePreferences();
      if (calendarType == 'google') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleCalendar(
              messageTemplate: _messageController.text,
              appendSentText: _appendSentTextController.text,
              appendConfirmedText: _appendConfirmedTextController.text, 
              appendDeclinedText: _appendDeclinedTextController.text
            ),
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
                decoration: const InputDecoration(labelText: 'Message. Special: [day], [hour].'),
                maxLines: 5,
                validator: (value) => _formTextValidator(value, 'Please enter a message.'),
              ),
              TextFormField(
                controller: _confirmationTextController,
                decoration: const InputDecoration(labelText: 'Confirmation Text'),
                validator: (value) => _formTextValidator(value, 'Please enter expected answer to accept appoitnment.'),
              ),
              TextFormField(
                controller: _declineTextController,
                decoration: const InputDecoration(labelText: 'Decline Text'),
                validator: (value) => _formTextValidator(value, 'Please enter expected answer to decline appointment.'),
              ),
              TextFormField(
                controller: _appendSentTextController,
                decoration: const InputDecoration(labelText: 'Sent Message Append Text'),
                validator: (value) => _formTextValidator(value, 'Please enter text to append to event with SMS sent.'),
              ),
              TextFormField(
                controller: _appendConfirmedTextController,
                decoration: const InputDecoration(labelText: 'Confirmed Appointment Append Text'),
                validator: (value) => _formTextValidator(value, 'Please enter text to append to confirmed event.'),
              ),              
              TextFormField(
                controller: _appendDeclinedTextController,
                decoration: const InputDecoration(labelText: 'Declined Appointment Append Text'),
                validator: (value) => _formTextValidator(value, 'Please enter text to append to declined event.'),
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