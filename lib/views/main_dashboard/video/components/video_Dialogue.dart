import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';

class VideoDialogues {
  Future<dynamic> showRewardsDialogue(BuildContext context) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Column(
              children: [
                Lottie.asset(
                  AppAnimations.dollarCoinChest,
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 10),
                HeaderTextBlack(
                  title: 'Earn Rewards for Watching Videos',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: BodyTextHint(
                title:
                    'For every video you watch, you will receive 2 SuperCoins as a reward.',
                fontSize: 14,
                fontWeight: FontWeight.w300,
                textAlign: TextAlign.start,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: HeaderTextPrimary(
                  title: 'Yes, I Got It',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Lottie.asset(
                      AppAnimations.dollarCoinChest,
                      height: 150,
                      width: 150,
                    ),
                  ),
                  SizedBox(height: 20),
                  HeaderTextBlack(
                    title: 'Earn Rewards for Watching Videos',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title:
                        'For every video you watch, you will receive 2 SuperCoins as a reward.',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 30),
                  GetRewardButton(
                    title: 'Yes, I Got It',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
