import 'package:url_launcher/url_launcher.dart';

class CustomLaunchers {
  static Future<void> makePhoneCall({required String phoneNumber}) async {
    final Uri launchUri = Uri(scheme: 'tel', path: '+91$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch tel';
    }
  }

  static Future<void> sendSms({required String phoneNumber}) async {
    final Uri launchUri = Uri(scheme: 'sms', path: '+91$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch sms';
    }
  }

  static Future<void> sendEmail({required String emailAddress}) async {
    final emailUri = Uri(scheme: 'mailto', path: emailAddress);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email';
    }
  }

  static Future<void> openWhatsApp({required String phoneNumber}) async {
    final Uri launchUri = Uri.parse('whatsapp://send?phone=+91$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch whatsapp';
    }
  }
}
