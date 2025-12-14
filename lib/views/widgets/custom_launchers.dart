import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class CustomLaunchers {
  CustomLaunchers._();

  static Future<void> makePhoneCall({
    required String phoneNumber,
    String countryCode = '+91',
  }) async {
    final uri = Uri(scheme: 'tel', path: '$countryCode$phoneNumber');
    await _launch(uri, 'Phone call');
  }

  static Future<void> sendSms({
    required String phoneNumber,
    String countryCode = '+91',
  }) async {
    final uri = Uri(scheme: 'sms', path: '$countryCode$phoneNumber');
    await _launch(uri, 'SMS');
  }

  static Future<void> sendEmail({
    required String emailAddress,
    String subject = '',
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {
        if (subject.isNotEmpty) 'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );
    await _launch(uri, 'Email');
  }

  static Future<void> openWhatsApp({
    required String phoneNumber,
    String countryCode = '+91',
    String message = '',
  }) async {
    final String formattedNumber = '$countryCode$phoneNumber';

    final Uri uri = Platform.isIOS
        ? Uri.parse(
            'https://wa.me/$formattedNumber'
            '${message.isNotEmpty ? '?text=${Uri.encodeComponent(message)}' : ''}',
          )
        : Uri.parse(
            'whatsapp://send?phone=$formattedNumber'
            '&text=${Uri.encodeComponent(message)}',
          );

    await _launch(uri, 'WhatsApp');
  }

  static Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
    String label = 'Location',
  }) async {
    final Uri uri = Platform.isIOS
        ? Uri.parse('https://maps.apple.com/?q=$latitude,$longitude')
        : Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($label)');

    await _launch(uri, 'Google Maps');
  }

  static Future<void> _launch(Uri uri, String featureName) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $featureName';
    }
  }
}
