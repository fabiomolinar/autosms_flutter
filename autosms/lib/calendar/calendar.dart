import 'dart:core';
import 'package:intl/intl.dart';

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