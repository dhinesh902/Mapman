import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mapman/controller/auth_controller.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:provider/provider.dart';

class CustomDialogues {
  static Future<void> showLoadingDialogue(BuildContext context) async {
    return showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            content: CupertinoActivityIndicator(
              radius: 15,
              color: AppColors.primary,
            ),
          );
        } else {
          return PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: ButtonProgressBar(),
            ),
          );
        }
      },
    );
  }

  Future showLogoutDialog(
    BuildContext context, {
    required String title,
    required bool isDeleteAccount,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (ctx) {
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
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  CustomDialogues.showLoadingDialogue(context);
                  try {
                    if (isDeleteAccount) {
                      await context.read<AuthController>().deleteAccount();
                    } else {
                      await context.read<AuthController>().logout();
                    }
                    SessionManager.clearSession();
                    if (!context.mounted) return;
                  } finally {
                    Navigator.of(context).pop();
                    Future.microtask(() {
                      if (!context.mounted) return;
                      context.goNamed(AppRoutes.login);
                    });
                  }
                },
                child: BodyTextColors(
                  title: isDeleteAccount ? 'Delete' : "Logout",
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
      builder: (ctx) {
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
                        title: isDeleteAccount ? 'Delete' : 'Logout',
                        isDialogue: true,
                        color: GenericColors.darkRed,
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          CustomDialogues.showLoadingDialogue(context);
                          try {
                            if (isDeleteAccount) {
                              await context
                                  .read<AuthController>()
                                  .deleteAccount();
                            } else {
                              await context.read<AuthController>().logout();
                            }
                            SessionManager.clearSession();
                            if (!context.mounted) return;
                          } finally {
                            Navigator.of(context).pop();
                            Future.microtask(() {
                              if (!context.mounted) return;
                              context.goNamed(AppRoutes.login);
                            });
                          }
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

  static Future showSuccessDialog(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    Future.delayed(const Duration(milliseconds: 1550), () {
      if (context.mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
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
                  title: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: body,
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
      barrierDismissible: false,
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
                  title: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: body,
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

  Future showDeleteDialog(
    BuildContext context, {
    String body = 'Video Permanently deleted by you',
  }) {
    Future.delayed(const Duration(milliseconds: 1550), () {
      if (context.mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
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
                  title: 'Deleted Successfully!!',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 10),
                BodyTextHint(
                  title: body,
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
      barrierDismissible: false,
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
                  title: body,
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

  Future<dynamic> showUpdateReviewDialogue(
    BuildContext context, {
    required VoidCallback onTap,
  }) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Column(
              children: [
                Image.asset(
                  AppIcons.updateChangeP,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 10),
                HeaderTextBlack(
                  title: 'Update Changes',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: BodyTextHint(
                  title: 'Are you sure you want to save these changes?',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: BodyTextHint(
                  title: 'Cancel',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () async {},
                child: BodyTextColors(
                  title: 'Save changes',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
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
                      AppIcons.updateChangeP,
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  HeaderTextBlack(
                    title: 'Update Changes',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title: 'Are you sure you want to save these changes?',
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
                            context.pop();
                          },
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: CustomFullButton(
                          title: 'Save Changes',
                          isDialogue: true,
                          onTap: () async {
                            Navigator.pop(context);
                            onTap();
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
