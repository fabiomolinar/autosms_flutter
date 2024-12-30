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
  
  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<bool> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      final GoogleSignInAccount? user = _currentUser;
        if (user != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Calendars'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: const Text('Google Calendars'),
        ));
  }
}