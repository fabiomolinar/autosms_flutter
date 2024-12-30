import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;

final GoogleSignIn _googleSignIn = GoogleSignIn(  
  scopes: <String>[google_calendar.CalendarApi.calendarScope],
);

class GoogleCalendar extends StatefulWidget {
  const GoogleCalendar({super.key});

  @override
  State createState() => GoogleCalendarState();
}

/// The state of the main widget.
class GoogleCalendarState extends State<GoogleCalendar> {
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

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

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