import 'dart:async';
import 'package:flutter/material.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'calendar.dart';

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
class GoogleCalendarState extends BaseCalendarState<GoogleCalendar> {
  GoogleSignInAccount? _currentUser;
  List<google_calendar.CalendarListEntry>? _calendars;
  
  @override
  void initState() {
    super.initState();
    // Set up listener to update user on user change.
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (account != null) {
        fetchCalendars();
      }
    });
    // Try to sign in silently.
    _googleSignIn.signInSilently();
  }  

  @override
  bool isSignedIn() {
    return _currentUser != null;
  }

  @override
  Future<bool> handleSignIn() async {
    try {      
      final GoogleSignInAccount? user = await _googleSignIn.signIn();      
      if (user != null) {
        print("Sign in successful."); // ignore: avoid_print
        _currentUser = user;          
        fetchCalendars();
        return true;
      } else {
        print("Sign in failed."); // ignore: avoid_print
        return false;
      }
    } catch (error) {
      print(error); // ignore: avoid_print
      return false;
    }
  }

  // Future<void> _handleSignOut() => _googleSignIn.disconnect(); // NOT USED.

  @override
  Future<void> fetchCalendars() async {
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');
    final calendarApi = google_calendar.CalendarApi(client!);
    final calendarList = await calendarApi.calendarList.list();
    setState(() {
      _calendars = calendarList.items;
    });
  }

  @override
  Future<void> fetchEvents(String calendarId) async {
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');
    final calendarApi = google_calendar.CalendarApi(client!);
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final eventsResult = await calendarApi.events.list(
      calendarId,
      timeMin: now.toUtc(),
      timeMax: tomorrow.toUtc(),
    );

    events = eventsResult.items?.where((event) => event.start?.dateTime != null).map((event) {
      return CalendarEvent(
        id: event.id!,
        summary: event.summary ?? '',
        description: event.description ?? '',
        startDate: event.start!.dateTime!,
        calendarType: CalendarType(name: 'Google', calendarInstance: this),
      );
    }).toList() ?? [];
    
    if (events!.isNotEmpty){
      sendSMS(events!, widget.messageTemplate);
    }
  } 

  @override
  Widget buildBody(){
    final GoogleSignInAccount? user = _currentUser;
    if (user == null){
      return Center(
        child: ElevatedButton(
          onPressed: handleSignIn,
          child: const Text('Sign in with Google'),
        ),
      );
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
              onTap: () => fetchEvents(calendar.id!),
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
          child: buildBody(),
        ));
  }
}