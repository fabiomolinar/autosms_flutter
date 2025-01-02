import 'dart:async';
import 'package:flutter/material.dart';
import 'calendar.dart' show BaseCalendarState, CalendarType;
import 'calendar.dart' as my_calendar show CalendarEvent;
import 'package:msal_auth/msal_auth.dart';
import 'package:microsoft_graph_api/microsoft_graph_api.dart';
import 'package:microsoft_graph_api/models/models.dart';
import '../environment.dart';

/// Singleton class that manages MSAL authentication.
final class MsalAuthService{
  MsalAuthService._();
  static final MsalAuthService instance = MsalAuthService._();

  final clientId = Environment.msalAadClientId;
  final scopes = [
    'https://graph.microsoft.com/calendar.read',
    'https://graph.microsoft.com/calendar.write',
  ];
  final prompt = Prompt.whenRequired;
  final broker = Broker.msAuthenticator;
  final authorityType = AuthorityType.aad; 
  SingleAccountPca? singleAccountPca;

  /// Creates the public client application based on the given account mode.
  Future<(bool, MsalException?)> createPublicClientApplication() async {
    final androidConfig = AndroidConfig(
      configFilePath: 'assets/msal_config.json',
      redirectUri: Environment.msalAadAndroidRedirectUri,
    );
    final appleConfig = AppleConfig(
      authorityType: authorityType,
      broker: broker,
    );
    try {
      singleAccountPca = await SingleAccountPca.create(
        clientId: clientId,
        androidConfig: androidConfig,
        appleConfig: appleConfig,
      );  
      return (true, null);
    } on MsalException catch (e) {
      print('Create public client application failed => $e'); // ignore: avoid_print
      return (false, e);
    }
  }

  Future<(AuthenticationResult?, MsalException?)> acquireToken() async {
    try {
      final result = await singleAccountPca?.acquireToken(
        scopes: scopes,
        prompt: prompt,
      );
      print('Acquire token => ${result?.toJson()}');  // ignore: avoid_print
      return (result, null);
    } on MsalException catch (e) {
      print('Acquire token failed => $e');  // ignore: avoid_print
      return (null, e);
    }
  }

  Future<(AuthenticationResult?, MsalException?)> acquireTokenSilent() async {
    try {
      final result = await singleAccountPca?.acquireTokenSilent(
        scopes: scopes,
      );
      print('Acquire token silent => ${result?.toJson()}'); // ignore: avoid_print
      return (result, null);
    } on MsalException catch (e) {
      print('Acquire token silent failed => $e'); // ignore: avoid_print

      // If it is a UI required exception, try to acquire token interactively.
      if (e is MsalUiRequiredException) {
        return acquireToken();
      }
      return (null, e);
    }
  }

  Future<(Account?, MsalException?)> getCurrentAccount() async {
    try {
      final result = await singleAccountPca?.currentAccount;
      print('Current account => ${result?.toJson()}');  // ignore: avoid_print
      return (result, null);
    } on MsalException catch (e) {
      print('Current account failed => $e');  // ignore: avoid_print
      return (null, e);
    }
  }

  Future<(bool, MsalException?)> signOut() async {
    try {
      final result = await singleAccountPca?.signOut();
      print('Sign out => $result'); // ignore: avoid_print
      return (true, null);
    } on MsalException catch (e) {
      print('Sign out failed => $e'); // ignore: avoid_print
      return (false, e);
    }
  }

}

class OutlookCalendar extends StatefulWidget {
  final String messageTemplate;

  const OutlookCalendar({super.key, required this.messageTemplate});

  @override
  State createState() => OutlookCalendarState();
}

/// The state of the main widget.
class OutlookCalendarState extends BaseCalendarState<OutlookCalendar> {
  AuthenticationResult? _authResult;
  List<Calendar>? _calendars;
  
  @override
  void initState() {
    super.initState();
    // Sign in if not already signed in.
    if (!isSignedIn()){
      handleSignIn();
    } 
    // Try to sign in silently.    
    signInSilently();
  }  

  @override
  bool isSignedIn() {
    return _authResult != null;
  }

  Future<void> signInSilently() async {
    final service = MsalAuthService.instance;
    final (authResult, authException) = await service.acquireTokenSilent();
    if (authResult != null){
      _authResult = authResult;
      fetchCalendars();
    } else {
      print('Failed to acquire token silently => $authException'); // ignore: avoid_print
    }
  }

  @override
  Future<bool> handleSignIn() async {
    final service = MsalAuthService.instance;
    final (pcaCreated, pcaException) = await service.createPublicClientApplication();
    if (pcaCreated){
      final (authResult, authException) = await service.acquireToken();
      _authResult = authResult;
      if (authResult != null){
        fetchCalendars();
        return true;
      } else {
        print('Failed to acquire token => $authException'); // ignore: avoid_print
        return false;
      }
    } else {
      print('Failed to create public client application => $pcaException'); // ignore: avoid_print
      return false;
    }    
  }
  
  // Future<void> _handleSignOut() => MsalAuthService.instance.signOut();

  @override
  Future<void> fetchCalendars() async {
    MSGraphAPI graphAPI = MSGraphAPI(_authResult!.accessToken);    
    final calendarApi = graphAPI.calendars;
    final calendarList = await calendarApi.fetchCalendars();
    setState(() {
      _calendars = calendarList;
    });
  }

  @override
  Future<void> fetchEvents(String calendarId) async {
    MSGraphAPI graphAPI = MSGraphAPI(_authResult!.accessToken);    
    final calendarApi = graphAPI.calendars;
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final eventsResult = await calendarApi.fetchCalendarEventsForRange(now, tomorrow);

    events = eventsResult.where((event) => event.startDateTime != null).map((event) {
      return my_calendar.CalendarEvent(
        id: event.id!,
        summary: event.subject ?? '',
        description: event.bodyPreview ?? '',
        startDate: DateTime.parse(event.startDateTime!),
        calendarType: CalendarType(name: 'Outlook', calendarInstance: this),
      );
    }).toList();
    
    if (events!.isNotEmpty){
      sendSMS(events!, widget.messageTemplate);
    }
  } 

  @override
  Future<void> updateEvents(List<my_calendar.CalendarEvent> events, String appendText) async {
    // TODO: Implement this method.
    throw UnimplementedError();
  }

  @override
  Widget buildBody(){
    final AuthenticationResult? authResult = _authResult;
    if (authResult == null){
      return Center(
        child: ElevatedButton(
          onPressed: handleSignIn,
          child: const Text('Sign in with Outlook'),
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
              title: Text(calendar.name),
              subtitle: Text(calendar.id),
              onTap: () => fetchEvents(calendar.id),
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
          title: const Text('Outlook Calendars'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: buildBody(),
        ));
  }
}