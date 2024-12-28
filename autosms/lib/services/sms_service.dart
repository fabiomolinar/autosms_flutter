import 'package:telephony/telephony.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;

  Future<void> sendSms(String number, String message) async {
    await telephony.sendSms(
      to: number,
      message: message,
    );
  }

  Future<void> readSms(Function(SmsMessage) onNewMessage) async {
    telephony.listenIncomingSms(
      onNewMessage: onNewMessage,
      listenInBackground: false,
    );
  }
}