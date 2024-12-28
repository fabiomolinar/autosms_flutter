import 'package:flutter/material.dart';
import 'calendar.dart';

class ConfigureCalendarScreen extends StatefulWidget {
  final Calendar calendar;
  final VoidCallback onSave;

  const ConfigureCalendarScreen({super.key, required this.calendar, required this.onSave});

  @override
  _ConfigureCalendarScreenState createState() => _ConfigureCalendarScreenState();
}

class _ConfigureCalendarScreenState extends State<ConfigureCalendarScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _smsMessageText;
  late String _smsConfirmationText;
  late String _appendText;

  @override
  void initState() {
    super.initState();
    _name = widget.calendar.name;
    _smsMessageText = widget.calendar.smsMessageText;
    _smsConfirmationText = widget.calendar.smsConfirmationText;
    _appendText = widget.calendar.appendText;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        widget.calendar.name = _name;
        widget.calendar.smsMessageText = _smsMessageText;
        widget.calendar.smsConfirmationText = _smsConfirmationText;
        widget.calendar.appendText = _appendText;
      });
      widget.onSave();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  _name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _smsMessageText,
                decoration: const InputDecoration(labelText: 'SMS Message Text'),
                onChanged: (value) {
                  _smsMessageText = value;
                },
                maxLines: 5, // Make the text box taller
              ),
              TextFormField(
                initialValue: _smsConfirmationText,
                decoration: const InputDecoration(labelText: 'SMS Confirmation Text'),
                onChanged: (value) {
                  _smsConfirmationText = value;
                },
              ),
              TextFormField(
                initialValue: _appendText,
                decoration: const InputDecoration(labelText: 'Append Text'),
                onChanged: (value) {
                  _appendText = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}