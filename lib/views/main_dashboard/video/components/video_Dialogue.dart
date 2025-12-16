import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';

class VideoDialogues {
  Future<dynamic> showRewardsDialogue(
    BuildContext context, {
    bool isEarnCoins = false,
  }) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Column(
              children: [
                if (isEarnCoins) ...[
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Lottie.asset(AppAnimations.confetti),
                          ),
                        ),
                        Lottie.asset(
                          AppAnimations.dollarCoinChest,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          AppIcons.goldCoinsP,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Image.asset(
                            AppIcons.goldP,
                            height: 80,
                            width: 80,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
              child: Center(
                child: BodyTextHint(
                  title: isEarnCoins
                      ? 'For every video you watch, you will receive 2 SuperCoins as a reward.'
                      : 'Use super coins to get exciting Benefits',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  textAlign: isEarnCoins ? TextAlign.start : TextAlign.center,
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: HeaderTextBlack(
                  title: 'Yes, I Got It',
                  fontSize: 14,
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
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                crossAxisAlignment: isEarnCoins
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (isEarnCoins) ...[
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Lottie.asset(AppAnimations.confetti),
                            ),
                          ),
                          Lottie.asset(
                            AppAnimations.dollarCoinChest,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            AppIcons.goldCoinsP,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Image.asset(
                              AppIcons.goldP,
                              height: 150,
                              width: 150,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 20),
                  HeaderTextBlack(
                    title: 'Earn Rewards for Watching Videos',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textAlign: isEarnCoins ? TextAlign.start : TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title: isEarnCoins
                        ? 'For every video you watch, you will receive 2 SuperCoins as a reward.'
                        : 'Use super coins to get exciting Benefits',
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    textAlign: isEarnCoins ? TextAlign.start : TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  GetRewardButton(
                    title: isEarnCoins
                        ? 'Yes, I Got It'
                        : 'Explore Super Coins',
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

  Future<dynamic> showViewedVideoDialogue(
    BuildContext context, {
    required bool turnOn,
  }) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Column(
              children: [
                Image.asset(
                  AppIcons.clockP,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 10),
                HeaderTextBlack(
                  title: turnOn
                      ? 'Turn on view history'
                      : 'Turn off view history',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: BodyTextHint(
                  title: turnOn
                      ? 'Are you sure you want to turn on view history?'
                      : 'Are you sure you want to turn off view history?',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: BodyTextHint(
                  title: 'Not Now',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () async {
                  await SessionManager.setVideoVideo(isVideoVideo: turnOn);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: BodyTextColors(
                  title: turnOn ? 'Turn On' : 'Turn Off',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: turnOn
                      ? GenericColors.darkGreen
                      : GenericColors.darkRed,
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
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      AppIcons.clockP,
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  HeaderTextBlack(
                    title: turnOn
                        ? 'Turn on view history'
                        : 'Turn off view history',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title: turnOn
                        ? 'Are you sure you want to turn on view history?'
                        : 'Are you sure you want to turn off view history?',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlineButton(
                          title: 'Not Now',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: CustomFullButton(
                          title: turnOn ? 'Turn On' : 'Turn Off',
                          isDialogue: true,
                          color: turnOn
                              ? GenericColors.darkGreen
                              : GenericColors.darkRed,
                          onTap: () async {
                            await SessionManager.setVideoVideo(
                              isVideoVideo: turnOn,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<dynamic> showVideoUploadDialogue(BuildContext context) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Column(
              children: [
                Image.asset(
                  AppIcons.multiMediaP,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 10),
                HeaderTextBlack(
                  title: 'Upload your Video File',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: BodyTextHint(
                  title: 'Please ensure the file size does not exceed 10MB',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: BodyTextHint(
                  title: 'Not Now',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  Future.microtask(() {
                    if (!context.mounted) return;
                    context.pushNamed(
                      AppRoutes.uploadVideo,
                      extra: VideosData(),
                    );
                  });
                },
                child: BodyTextColors(
                  title: 'Upload',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
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
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      AppIcons.multiMediaP,
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  HeaderTextBlack(
                    title: 'Upload your Video File',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title: 'Please ensure the file size does not exceed 10MB',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlineButton(
                          title: 'Not Now',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: CustomFullButton(
                          title: 'Upload',
                          isDialogue: true,
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.pop(context);
                            Future.microtask(() {
                              if (!context.mounted) return;
                              context.pushNamed(
                                AppRoutes.uploadVideo,
                                extra: VideosData(),
                              );
                            });
                          },
                        ),
                      ),
                    ],
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
