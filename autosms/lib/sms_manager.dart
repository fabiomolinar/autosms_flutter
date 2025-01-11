import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'utils.dart' show MySimpleDialog;

class SMS {
  String _telephoneNumber;
  final String message;

  SMS({required String telephoneNumber, required this.message})
      : _telephoneNumber = _formatPhoneNumber(telephoneNumber);

  String get telephoneNumber => _telephoneNumber;

  set telephoneNumber(String telephoneNumber) {
    _telephoneNumber = _formatPhoneNumber(telephoneNumber);
  }

  static String _formatPhoneNumber(String number) {
    // Remove all spaces and new lines
    number = number.replaceAll(RegExp(r'\s+'), '');
    // Ensure the number starts with +48
    if (!number.startsWith('+48')) {
      if (number.startsWith('48')) {
        number = '+$number';
      } else {
        number = '+48$number';
      }
    }
    return number;
  }
}

Future<void> sendAllSMS(List<SMS> messages) async {
  for (var sms in messages) {
    final telephony = Telephony.instance;
    try {
      await telephony.sendSms(to: sms.telephoneNumber, message: sms.message);
    } catch (error) {
      print('Failed to send SMS: $error'); // ignore: avoid_print
    }
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
          .greaterThanOrEqualTo(from.millisecondsSinceEpoch.toString())
          .and(SmsColumn.DATE)
          .lessThanOrEqualTo(to.millisecondsSinceEpoch.toString()),
    );
    return messages.map((sms) {
      return SMS(
        telephoneNumber: sms.address ?? 'Unknown',
        message: sms.body ?? 'No message',
      );
    }).toList();
  }
}