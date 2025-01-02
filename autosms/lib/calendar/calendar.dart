import 'dart:core';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../sms_manager.dart';
import '../utils.dart' show MySimpleDialog;

abstract class BaseCalendarState<T extends StatefulWidget> extends State<T> {
  List<CalendarEvent>? events;

  bool isSignedIn();
  Future<bool> handleSignIn();
  Future<void> handleSignOut();
  Future<void> fetchCalendars();
  Future<void> fetchEvents(String calendarId);
  Future<void> updateEvents(List<CalendarEvent> events, String appendText);
  Future<void> verifySMS(String calendarId);
  Future<void> sendSMS(List<CalendarEvent> events, String messageTemplate) async {
    List<SMS> smsList = [];
    for (var event in events) {
      String? phoneNumber = event.findPhoneNumber();
      if (phoneNumber != null) {
        String message = event.createMessage(messageTemplate);
        smsList.add(SMS(telephoneNumber: phoneNumber, message: message));
      }
    }

    if (smsList.isNotEmpty) {
      await sendAllSMS(smsList);
      var smsCount = smsList.length;
      showDialog(
        context: context,
        builder: (BuildContext context) => MySimpleDialog(message: '$smsCount SMS messages were sent.'),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => MySimpleDialog(message: '0 SMS messages were sent.'),
      );
    }
  }
  // ignore: unused_element
  void showCalendarOptionsDialog(String calendarId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select an Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  fetchEvents(calendarId);
                },
                child: const Text('Send SMS'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  verifySMS(calendarId);
                },
                child: const Text('Verify SMS'),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget buildBody();
}

class CalendarType {
  final String name;
  final dynamic calendarInstance;

  CalendarType({required this.name, required this.calendarInstance});
}

class CalendarEvent {
  final String id;
  final String summary;
  final String description;
  final DateTime startDate;
  final CalendarType calendarType;

  CalendarEvent({
    required this.id,
    required this.summary,
    required this.description,
    required this.startDate,
    required this.calendarType,
  });

  String? findPhoneNumber() {
    // Specific for Poland only.
    final phoneNumberPattern = RegExp(r'(\+48\s?|48\s?)?(\d{3}\s?\d{3}\s?\d{3}|\d{3}\s?\d{2}\s?\d{2}\s?\d{2})');
    final match = phoneNumberPattern.firstMatch(summary) ?? phoneNumberPattern.firstMatch(description);
    if (match != null) {
      String phoneNumber = match.group(0)!.replaceAll(RegExp(r'\s+'), '');
      if (!phoneNumber.startsWith('+48')) {
        if (phoneNumber.startsWith('48')) {
          phoneNumber = '+$phoneNumber';
        } else {
          phoneNumber = '+48$phoneNumber';
        }
      }
      return phoneNumber;
    }
    return null;
  }

  String createMessage(String template) {
    final DateFormat dateFormatter = DateFormat.yMd(Intl.getCurrentLocale());
    final DateFormat timeFormatter = DateFormat.Hm(Intl.getCurrentLocale());

    String day = dateFormatter.format(startDate);
    String hour = timeFormatter.format(startDate);

    return template
        .replaceAll('[day]', day)
        .replaceAll('[hour]', hour);
  }
}