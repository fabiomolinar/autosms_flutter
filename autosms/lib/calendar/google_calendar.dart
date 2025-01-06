import 'dart:async';
import 'package:autosms/sms_manager.dart';
import 'package:flutter/material.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar.dart';
import '../utils.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(  
  scopes: <String>[google_calendar.CalendarApi.calendarScope],
);

class GoogleCalendar extends StatefulWidget {
  final String messageTemplate;
  final String appendSentText;
  final String appendConfirmedText;
  final String appendDeclinedText;
  final String confirmationText;
  final String declineText;

  const GoogleCalendar({
    super.key, required this.messageTemplate,
    required this.appendSentText, required this.appendConfirmedText, 
    required this.appendDeclinedText, required this.confirmationText,
    required this.declineText,
  });

  @override
  State createState() => GoogleCalendarState();
}

/// The state of the main widget.
class GoogleCalendarState extends BaseCalendarState<GoogleCalendar> {
  GoogleSignInAccount? _currentUser;
  List<google_calendar.CalendarListEntry>? _calendars;
  String _selectedCalendarId = '';
  final String _lastTimeSentKey = 'lastTimeSent';
  
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

  @override
  Future<void> handleSignOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
      _calendars = null;
    });
  } 

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

  Future<List<CalendarEvent>?> _getTomorrowsEvents(calendarId) async {
    _selectedCalendarId = calendarId;
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing!');
    final calendarApi = google_calendar.CalendarApi(client!);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59, 59); // End of the next day
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
    return events;
  }

  @override
  Future<void> fetchEvents(String calendarId) async {
    events = await _getTomorrowsEvents(calendarId);
    if (events!.isNotEmpty){
      sendSMS(events!, widget.messageTemplate);
      // Save last time sent
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_lastTimeSentKey, DateTime.now().toString());
      // Update events title      
      updateEvents(events!, widget.appendSentText);
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => MySimpleDialog(message: 'No events found.'),
        );
      }
    }
  } 

  @override
  Future<void> updateEvents(List<CalendarEvent> events, String appendText) async {
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    final calendarApi = google_calendar.CalendarApi(client!);
    final regex = RegExp(r'^\[.*?\]');

    for (var event in events) {
      var googleEvent = await calendarApi.events.get(_selectedCalendarId, event.id);
      String updatedTitle;
      
      if (regex.hasMatch(googleEvent.summary!)) {
        updatedTitle = googleEvent.summary!.replaceFirst(regex, appendText);
      } else {
        updatedTitle = "$appendText ${googleEvent.summary!}";
      }

      googleEvent.summary = updatedTitle;
      await calendarApi.events.update(googleEvent, _selectedCalendarId, event.id);
    }
  }

  @override
  Future<void> verifySMS(String calendarId) async {
    events = await _getTomorrowsEvents(calendarId);
    final prefs = await SharedPreferences.getInstance();
    final String? lastTimeSent = prefs.getString(_lastTimeSentKey);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    final lastTimeSentDate = DateTime.parse(lastTimeSent ?? today.toString());
    final from = lastTimeSentDate.isAfter(today) ? lastTimeSentDate : today;
    if (context.mounted && events!.isNotEmpty) {
      final smsList = await readAllSMS(context, from, DateTime.now());
      for (var event in events!){        
        final phoneNumber = event.findPhoneNumber();
        if (phoneNumber != null){
          for (var sms in smsList.toList()){
            if (sms.telephoneNumber == phoneNumber){
              final smsMsg = sms.message.toLowerCase();
              if (smsMsg == widget.confirmationText.toLowerCase()){
                updateEvents([event], widget.appendConfirmedText);
              } else if (smsMsg == widget.declineText.toLowerCase()){
                updateEvents([event], widget.appendDeclinedText);
              }
            }
          }
        }      
      }    
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
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _calendars!.length,
                itemBuilder: (BuildContext context, int index){
                  final calendar = _calendars![index];
                  return ListTile(
                    title: Text(calendar.summary ?? ''),
                    onTap: () => showCalendarOptionsDialog(calendar.id!),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0), 
              child: ElevatedButton(
                onPressed: handleSignOut, child: const Text('Sign Out'),
              )
            )
          ],
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