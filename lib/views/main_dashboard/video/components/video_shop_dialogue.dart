import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/home/home.dart';
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

  Future<dynamic> showReportShopDialogue(
    BuildContext context, {
    required String shopName,
    required String shopLocation,
  }) async {
    String? selectedReport;
    final TextEditingController reasonController = TextEditingController();

    final List<String> reports = [
      'Fake/Scam',
      'Wrong Information',
      'Closed Permanently',
      'Others',
    ];

    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    HeaderTextBlack(
                      title: 'Report This Shop',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 5),
                    BodyTextHint(
                      title: '$shopName • $shopLocation',
                      fontSize: 12,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                content: Column(
                  children: [
                    const SizedBox(height: 10),
                    Column(
                      children: reports.map((report) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedReport = report;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  selectedReport == report
                                      ? CupertinoIcons.largecircle_fill_circle
                                      : CupertinoIcons.circle,
                                  size: 20,
                                  color: selectedReport == report
                                      ? CupertinoColors.activeBlue
                                      : CupertinoColors.systemGrey,
                                ),
                                SizedBox(width: 15),
                                Flexible(
                                  child: HeaderTextBlack(
                                    title: report,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    /// Others Input
                    if (selectedReport == 'Others') ...[
                      const SizedBox(height: 10),
                      CupertinoTextField(
                        controller: reasonController,
                        placeholder: 'Please Enter Your Reason',
                        maxLines: 3,
                        padding: const EdgeInsets.all(10),
                      ),
                    ],
                  ],
                ),

                actions: [
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Report'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: Dialog(
                  elevation: 0,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleContainer(
                                color: AppColors.primary.withValues(alpha: .05),
                                onTap: () {},
                                child: Center(
                                  child: Image.asset(
                                    AppIcons.alertShopP,
                                    height: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HeaderTextBlack(
                                      title: 'Report This Shop',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    BodyTextHint(
                                      title: '$shopName • $shopLocation',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),
                          const Divider(color: Color(0XFFE0E0E0)),
                          const SizedBox(height: 10),
                          Column(
                            children: reports.map((report) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedReport = report;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: report,
                                        groupValue: selectedReport,
                                        activeColor: AppColors.primary,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedReport = value;
                                          });
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      const SizedBox(width: 10),
                                      BodyTextColors(
                                        title: report,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.darkText,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          if (selectedReport == 'Others') ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0XFFF2F2F2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TextField(
                                controller: reasonController,
                                maxLines: 3,
                                cursorColor: AppColors.primary,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Please Enter Your Reason',
                                  hintStyle: AppTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.lightGreyHint,
                                  ).textStyle,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(
                                child: CustomOutlineButton(
                                  title: 'Cancel',
                                  onTap: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: CustomFullButton(
                                  title: 'Report',
                                  isDialogue: true,
                                  color: const Color(0XFFCC0000),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
