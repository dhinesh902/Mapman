import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Stack(
              fit: StackFit.loose,
              alignment: Alignment.center,
              children: [
                Image.asset(
                  AppIcons.onboardP,
                  height: MediaQuery.of(context).size.height / 2,
                  width: 249,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BlurContainer(),
                ),
              ],
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: HeaderTextBlack(
                title: 'Boost Your Shop’s \nwith best & affordable \nway',
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 30),
            GetStartedButton(
              onTap: () {
                SessionManager.setString(key: Keys.isFirstTime, value: 'true');
                context.go('/login');
              },
            ),
            SizedBox(height: 30),
            Center(
              child: BodyTextHint(
                title: 'By Continuing you agree to Mapman',
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {},
                child: HeaderTextPrimary(
                  title: 'Terms and Conditions',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  textDecoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class BlurContainer extends StatelessWidget {
  const BlurContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: AppColors.whiteText, blurRadius: 5, spreadRadius: 5),
        ],
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.whiteText.withValues(alpha: 0.6),
                    GenericColors.lightPrimary.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class BlurContainer extends StatelessWidget {
//   const BlurContainer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 20,
//       width: double.infinity,
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 10),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.whiteText.withValues(alpha: 0.6),
//               GenericColors.lightPrimary.withValues(alpha: .5),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
