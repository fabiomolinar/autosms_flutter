import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'calendar.dart';
import 'sms_manager.dart';
import 'utils.dart' show SimpleDialog;

final GoogleSignIn _googleSignIn = GoogleSignIn(  
  scopes: <String>[google_calendar.CalendarApi.calendarScope],
);

class GoogleCalendar extends StatefulWidget {
  final String messageTemplate;

  const GoogleCalendar({super.key, required this.messageTemplate});

  @override
  State createState() => GoogleCalendarState();
}

/// The state of the main widget.
class GoogleCalendarState extends State<GoogleCalendar> {
  GoogleSignInAccount? _currentUser;
  List<google_calendar.CalendarListEntry>? _calendars;
  List<CalendarEvent>? _events;
  
  @override
  void initState() {
    super.initState();
    // Set up listener to update user on user change.
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (account != null) {
        _fetchCalendars();
      }
    });
    // Try to sign in silently.
    _googleSignIn.signInSilently();
  }

  bool isSignedIn() {
    return _currentUser != null;
  }

  Future<bool> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      final GoogleSignInAccount? user = _currentUser;
        if (user != null) {
          _fetchCalendars();
          return true;
        } else {
          return false;
        }
    } catch (error) {
      print(error); // ignore: avoid_print
      return false;
    }
  }

  // Future<void> _handleSignOut() => _googleSignIn.disconnect(); // NOT USED.

  Future<void> _fetchCalendars() async {
    final authHeaders = await _googleSignIn.currentUser?.authHeaders;
    if (authHeaders == null) {
      print('Missing auth headers'); // ignore: avoid_print
      return;
    }
    final client = authenticatedClient(Client(), AccessCredentials.fromHeaders(authHeaders));
    final calendarApi = google_calendar.CalendarApi(client);
    final calendarList = await calendarApi.calendarList.list();
    setState(() {
      _calendars = calendarList.items;
    });
  }

  Future<void> _fetchEvents(String calendarId) async {
    final authHeaders = await _googleSignIn.currentUser?.authHeaders;
    if (authHeaders == null) {
      print('Missing auth headers'); // ignore: avoid_print
      return;
    }
    final client = authenticatedClient(Client(), AccessCredentials.fromHeaders(authHeaders));
    final calendarApi = google_calendar.CalendarApi(client);
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final events = await calendarApi.events.list(
      calendarId,
      timeMin: now.toUtc(),
      timeMax: tomorrow.toUtc(),
    );

    List<CalendarEvent> calendarEvents = events.items?.where((event) => event.start?.dateTime != null).map((event) {
      return CalendarEvent(
        id: event.id!,
        summary: event.summary ?? '',
        description: event.description ?? '',
        startDate: event.start!.dateTime!,
        calendarType: CalendarType(name: 'Google', calendarInstance: this),
      );
    }).toList() ?? [];

    List<SMS> smsList = [];
    for (var event in calendarEvents) {
      String? phoneNumber = event.findPolishPhoneNumber();
      if (phoneNumber != null) {
        String message = event.createMessage(widget.messageTemplate);
        smsList.add(SMS(telephoneNumber: phoneNumber, message: message));
      }
    }

    if (smsList.isNotEmpty) {
      await sendSMS(smsList);
      smsCount = smsList.length;
      showDialog(
        context: context,
        builder: (BuildContext context) => SimpleDialog(message: '$smsCount SMS messages were sent.'),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => SimpleDialog(message: '0 SMS messages were sent.'),
      );
    }
  }

  Widget _buildBody(){
    final GoogleSignInAccount? user = _currentUser;
    if (user == null){
      return Center(
        child: ElevatedButton(
          onPressed: handleSignIn,
          child: const Text('Sign in with Google'),
        ),
      )
    } else {
      if (_calendars == null){
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return ListView.builder(
          itemCount: _calendars!.length,
          itemBuilder: (BuildContext context, int index){
            final calendar = _calendars![index];
            return ListTile(
              title: Text(calendar.summary ?? ''),
              subtitle: Text(calendar.id ?? ''),
              onTap: () => _handleCalendarSelected(calendar.id!),
            );
          },
        );  
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Calendars'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}