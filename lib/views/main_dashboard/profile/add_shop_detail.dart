import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';

class AddShopDetail extends StatefulWidget {
  const AddShopDetail({super.key});

  @override
  State<AddShopDetail> createState() => _AddShopDetailState();
}

class _AddShopDetailState extends State<AddShopDetail> {
  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Shop Details'),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Container(
              height: 277,
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadiusGeometry.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppIcons.shopP, height: 80, width: 80),
                    SizedBox(height: 10),
                    BodyTextHint(
                      title: 'Please Add your shop Details',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                    SizedBox(height: 15),
                    InkWell(
                      onTap: () async {
                        await showAddShopDetail(context);
                      },
                      child: HeaderTextPrimary(
                        title: 'Add Details',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        textDecoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
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

Future<dynamic> showAddShopDetail(BuildContext context) async {
  if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Column(
            children: [
              Image.asset(AppIcons.storeP, height: 100),
              SizedBox(height: 10),
              HeaderTextBlack(
                title: 'Add Shop Details',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          content: BodyTextHint(
            title: 'To post your reels or video, Please register your shop',
            fontSize: 12,
            fontWeight: FontWeight.w300,
            textAlign: TextAlign.center,
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: BodyTextHint(
                title: 'Not Now',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed(AppRoutes.registerShopDetail);
              },
              child: HeaderTextPrimary(
                title: 'Register',
                fontSize: 14,
                fontWeight: FontWeight.w400,
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
        insetPadding: EdgeInsets.symmetric(horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppIcons.storeP, height: 131, width: 131),
              SizedBox(height: 15),
              HeaderTextBlack(
                title: 'Add Shop Details',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 15),
              BodyTextHint(
                title: 'To post your reels or video, Please register your shop',
                fontSize: 12,
                fontWeight: FontWeight.w300,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomOutlineButton(
                      title: 'Not Now',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: CustomFullButton(
                      title: 'Register',
                      isDialogue: true,
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(AppRoutes.registerShopDetail);
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
