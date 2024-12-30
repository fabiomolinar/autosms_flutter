import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:another_telephony/telephony.dart';
import 'utils.dart' show MySimpleDialog;

class SMS {
  final String telephoneNumber;
  final String message;

  SMS({required this.telephoneNumber, required this.message});
}

Future<void> sendAllSMS(List<SMS> messages) async {
  for (var sms in messages) {
    await () async {
      try {
        String result = await sendSMS(
          message: sms.message,
          recipients: [sms.telephoneNumber],
        );
        print(result); // ignore: avoid_print
      } catch (error) {
        print('Failed to send SMS: $error'); // ignore: avoid_print
      }
    }();
  }
}

Future<List<SMS>> readAllSMS(BuildContext context, DateTime from, DateTime to) async {
  final telephony = Telephony.instance;
  final bool? permissionGranted = await telephony.requestPhoneAndSmsPermissions;
  if (permissionGranted == false) {
    showDialog(
      context: context,
      builder: (BuildContext context) => MySimpleDialog(message: "Permission to read SMS denied."),
    );
    return [];
  } else {
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      filter: SmsFilter.where(SmsColumn.DATE)
          .greaterThanOrEqualTo(from.toIso8601String())
          .and(SmsColumn.DATE)
          .lessThanOrEqualTo(to.toIso8601String()),
    );
    return messages.map((sms) {
      return SMS(
        telephoneNumber: sms.address ?? 'Unknown',
        message: sms.body ?? 'No message',
      );
    }).toList();
  }
}