import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';

class CustomDialogues {
  Future showLogoutDialog(BuildContext context, {required String title}) {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Column(
              children: [
                SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    AppIcons.logoutImgP,
                    height: 90,
                    width: 90,
                  ),
                ),
                SizedBox(height: 20),
                HeaderTextBlack(
                  title: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: 'Are you sure you want to close your current profile?',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: BodyTextColors(
                  title: "Not Now",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {},
                child: BodyTextColors(
                  title: "Logout",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GenericColors.darkRed,
                ),
              ),
            ],
          );
        },
      );
    }

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: AppColors.scaffoldBackground,
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    AppIcons.logoutImgP,
                    height: 130,
                    width: 130,
                  ),
                ),
                SizedBox(height: 20),
                HeaderTextBlack(
                  title: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: 'Are you sure you want to close your current profile?',
                  fontSize: 12,
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
                        title: 'Logout',
                        isDialogue: true,
                        color: GenericColors.darkRed,
                        onTap: () {},
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

  Future showSuccessDialog(BuildContext context) {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Column(
              children: [
                SizedBox(height: 10),
                Center(
                  child: Lottie.asset(
                    AppAnimations.success,
                    height: 60,
                    width: 60,
                  ),
                ),
                SizedBox(height: 20),
                HeaderTextBlack(
                  title: 'Successfully Updated!!',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: 'Shop details successfully submitted by you',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    }

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: AppColors.scaffoldBackground,
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Center(
                  child: Lottie.asset(
                    AppAnimations.success,
                    height: 80,
                    width: 80,
                  ),
                ),
                SizedBox(height: 20),
                HeaderTextBlack(
                  title: 'Successfully Updated!!',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: 'Shop details successfully submitted by you',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future showDeleteDialog(BuildContext context) {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Column(
              children: [
                SizedBox(height: 10),
                Center(
                  child: Image.asset(AppIcons.trashP, height: 40, width: 40),
                ),
                SizedBox(height: 20),
                HeaderTextBlack(
                  title: 'Successfully Updated!!',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: 'Shop details successfully submitted by you',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    }

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: AppColors.scaffoldBackground,
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Center(
                  child: Image.asset(AppIcons.trashP, height: 40, width: 40),
                ),
                SizedBox(height: 20),
                HeaderTextBlack(
                  title: 'Deleted Successfully!!',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: 'Video Permanently deleted by you',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> showRatingDialog(BuildContext context) {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(content: _RatingDialogContent());
        },
      );
    } else {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: _RatingDialogContent(),
          );
        },
      );
    }
  }
}

class _RatingDialogContent extends StatefulWidget {
  const _RatingDialogContent();

  @override
  State<_RatingDialogContent> createState() => _RatingDialogContentState();
}

class _RatingDialogContentState extends State<_RatingDialogContent> {
  final ValueNotifier<int> rating = ValueNotifier(1);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            width: double.maxFinite,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Opacity(
                    opacity: .1,
                    child: Image.asset(
                      AppIcons.ratingStarP,
                      height: 180,
                      width: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(top: 10, child: Image.asset(AppIcons.ratingHandP)),
                ],
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              HeaderTextBlack(
                title: "Rate Our Application",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 10),
              BodyTextHint(
                title:
                    'If you enjoy using this app, would you mind taking a moment to rate it? Thanks for the support',
                fontSize: 14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder(
                valueListenable: rating,
                builder: (context, value, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () => rating.value = index + 1,
                        child: Image.asset(
                          index < value
                              ? AppIcons.ratingStarP
                              : AppIcons.ratingStarOutlineP,
                          height: 30,
                          width: 30,
                          color: index < value ? null : AppColors.darkGrey,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: GenericColors.uploadPrimary,
                  borderRadius: BorderRadius.circular(30),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () {},
                  child: BodyTextColors(
                    title: 'Rate Now',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.whiteText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: BodyTextHint(
                  title: 'Skip',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 200,
            width: double.maxFinite,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Opacity(
                    opacity: .1,
                    child: Image.asset(
                      AppIcons.ratingStarP,
                      height: 180,
                      width: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 97,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.whiteText,
                            GenericColors.homeTopPrimary,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 50,
                          width: 130,
                          decoration: const BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(200),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(top: 10, child: Image.asset(AppIcons.ratingHandP)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                HeaderTextBlack(
                  title: "Rate Our Application",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 10),
                BodyTextHint(
                  title:
                      'If you enjoy using this app, would you mind taking a moment to rate it? Thanks for the support',
                  fontSize: 14,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder(
                  valueListenable: rating,
                  builder: (context, value, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () => rating.value = index + 1,
                          child: Image.asset(
                            index < value
                                ? AppIcons.ratingStarP
                                : AppIcons.ratingStarOutlineP,
                            height: 30,
                            width: 30,
                            color: index < value ? null : AppColors.darkGrey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GenericColors.uploadPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: BodyTextColors(
                      title: 'Rate Now',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.whiteText,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: BodyTextHint(
                    title: 'Skip',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
