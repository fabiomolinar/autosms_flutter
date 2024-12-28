import 'package:googleapis/calendar/v3.dart' as google_calendar;

abstract class Calendar {
  String name;
  String smsMessageText;
  String smsConfirmationText;
  String appendText;

  Calendar({
    required this.name,
    this.smsMessageText = 'Aby potwierdzić wizytę, odpowiedz „TAK” na tę wiadomość.',
    this.smsConfirmationText = 'TAK',
    this.appendText = '[P]',
  });

  Future<List<dynamic>> readEvents();
  Future<void> updateEvent(google_calendar.Event event);
}