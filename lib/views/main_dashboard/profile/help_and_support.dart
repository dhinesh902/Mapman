import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_launchers.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';

class HelpAndSupport extends StatefulWidget {
  const HelpAndSupport({super.key});

  @override
  State<HelpAndSupport> createState() => _HelpAndSupportState();
}

class _HelpAndSupportState extends State<HelpAndSupport> {
  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Help & Support'),
        body: ListView(
          children: [
            SizedBox(height: 15),
            ProfileListTile(
              image: AppIcons.smsP,
              title: 'SMS',
              body: 'Connect With Our Support Team',
              onTap: () async {
                await CustomLaunchers.sendSms(phoneNumber: '9791543756');
              },
            ),
            SizedBox(height: 15),
            ProfileListTile(
              image: AppIcons.gmailP,
              title: 'Email',
              body: 'Email us at support@mapman.com',
              onTap: () async {
                await CustomLaunchers.sendEmail(
                  emailAddress: 'dhineshbabu9025@gmail.com',
                );
              },
            ),
            SizedBox(height: 15),
            ProfileListTile(
              image: AppIcons.callP,
              title: 'Call',
              body: '+91 9791543756',
              onTap: () async {
                await CustomLaunchers.makePhoneCall(phoneNumber: '9791543756');
              },
            ),
            SizedBox(height: 15),
            ProfileListTile(
              image: AppIcons.whatsappP,
              title: 'Whats app',
              body: 'Connect With Our Support Team',
              onTap: () async {
                await CustomLaunchers.openWhatsApp(phoneNumber: '9025821501');
              },
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  const ProfileListTile({
    super.key,
    required this.image,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String image, title, body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Image.asset(image, height: 30, width: 30, fit: BoxFit.contain),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderTextBlack(
                    title: title,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 5),
                  BodyTextHint(
                    title: body,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
