import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'calendar.dart';

class GoogleCalendar extends Calendar {
  GoogleCalendar({
    required super.name,
    super.smsMessageText,
    super.smsConfirmationText,
    super.appendText,
  });

  static const _clientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const _clientSecret = 'YOUR_GOOGLE_CLIENT_SECRET';
  static const _scopes = [google_calendar.CalendarApi.calendarScope];

  Future<google_calendar.CalendarApi> _getGoogleCalendarApi() async {
    final client = await clientViaUserConsent(
      ClientId(_clientId, _clientSecret),
      _scopes,
      (url) {
        // Open the URL in the browser for user consent
        print('Please go to the following URL and grant access:');
        print('  => $url');
        print('');
      },
    );
    return google_calendar.CalendarApi(client);
  }

  @override
  Future<List<google_calendar.Event>> readEvents() async {
    final calendarApi = await _getGoogleCalendarApi();
    final events = await calendarApi.events.list('primary');
    return events.items ?? [];
  }

  @override
  Future<void> updateEvent(google_calendar.Event event) async {
    final calendarApi = await _getGoogleCalendarApi();
    await calendarApi.events.update(event, 'primary', event.id!);
  }
}