import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';

class VideoShopDialogue {
  Future<dynamic> showSaveOrRemoveShopDialogue(
    BuildContext context, {
    required bool isRemoveShop,
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
                  isRemoveShop ? AppIcons.removeShopP : AppIcons.saveShopP,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 10),
                HeaderTextBlack(
                  title: isRemoveShop ? 'Remove this shop?' : 'Save this shop?',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: BodyTextHint(
                  title: isRemoveShop
                      ? 'This shop will be removed from your saved list.'
                      : 'This shop will be added to your saved list.',
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
                  Navigator.pop(context);
                  onTap();
                },
                child: BodyTextColors(
                  title: isRemoveShop ? 'Remove Shop' : 'Save Shop',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isRemoveShop
                      ? GenericColors.darkRed
                      : AppColors.primary,
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
                      isRemoveShop ? AppIcons.removeShopP : AppIcons.saveShopP,
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  HeaderTextBlack(
                    title: isRemoveShop
                        ? 'Remove this shop?'
                        : 'Save this shop?',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title: isRemoveShop
                        ? 'This shop will be removed from your saved list.'
                        : 'This shop will be added to your saved list.',
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
                          title: isRemoveShop ? 'Remove Shop' : 'Save Shop',
                          isDialogue: true,
                          color: isRemoveShop
                              ? GenericColors.darkRed
                              : AppColors.primary,
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

  Future<dynamic> showSaveOrRemoveVideoDialogue(
    BuildContext context, {
    required bool isRemoveShop,
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
                  isRemoveShop ? AppIcons.removeVideoP : AppIcons.saveVideoP,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 10),
                HeaderTextBlack(
                  title: isRemoveShop
                      ? 'Remove this Video?'
                      : 'Save this Video?',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: BodyTextHint(
                  title: isRemoveShop
                      ? 'This Video will be removed from your saved list.'
                      : 'This Video will be added to your saved list.',
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
                  Navigator.pop(context);
                  onTap();
                },
                child: BodyTextColors(
                  title: 'Save Video',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isRemoveShop
                      ? GenericColors.darkRed
                      : AppColors.primary,
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
                      isRemoveShop
                          ? AppIcons.removeVideoP
                          : AppIcons.saveVideoP,
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  HeaderTextBlack(
                    title: isRemoveShop
                        ? 'Remove this Video?'
                        : 'Save this Video?',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title: isRemoveShop
                        ? 'This Video will be removed from your saved list.'
                        : 'This Video will be added to your saved list.',
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
                          title: isRemoveShop ? 'Remove Video' : 'Save Video',
                          isDialogue: true,
                          color: isRemoveShop
                              ? GenericColors.darkRed
                              : AppColors.primary,
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
