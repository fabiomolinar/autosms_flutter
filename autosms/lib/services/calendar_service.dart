import 'dart:convert';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class CalendarService {
  final Logger _logger = Logger('CalendarService');

  // Google Calendar
  Future<google_calendar.CalendarApi> _getGoogleCalendarApi() async {
    var clientId = ClientId('YOUR_GOOGLE_CLIENT_ID', 'YOUR_GOOGLE_CLIENT_SECRET');
    var scopes = [google_calendar.CalendarApi.calendarScope];

    var authClient = await clientViaUserConsent(clientId, scopes, (url) {
      _logger.info('Please go to the following URL and grant access:');
      _logger.info('  => $url');
    });

    return google_calendar.CalendarApi(authClient);
  }

  // Outlook Calendar
  Future<http.Client> _getOutlookCalendarApi() async {
    var clientId = 'YOUR_OUTLOOK_CLIENT_ID';
    var clientSecret = 'YOUR_OUTLOOK_CLIENT_SECRET';
    var scopes = ['https://graph.microsoft.com/.default'];

    var authClient = await clientViaUserConsent(
      ClientId(clientId, clientSecret),
      scopes,
      (url) {
        _logger.info('Please go to the following URL and grant access:');
        _logger.info('  => $url');
      },
    );

    return authClient;
  }

  Future<List<google_calendar.Event>> getGoogleCalendarEvents() async {
    var calendarApi = await _getGoogleCalendarApi();
    var events = await calendarApi.events.list('primary', timeMin: DateTime.now().toUtc());
    return events.items ?? [];
  }

  Future<List<Map<String, dynamic>>> getOutlookCalendarEvents() async {
    var client = await _getOutlookCalendarApi();
    var response = await client.get(
      Uri.parse('https://graph.microsoft.com/v1.0/me/events'),
      headers: {'Authorization': 'Bearer YOUR_ACCESS_TOKEN'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['value']);
    } else {
      throw Exception('Failed to load events');
    }
  }
}