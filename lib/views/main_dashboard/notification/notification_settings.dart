import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:provider/provider.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late HomeController homeController;

  @override
  void initState() {
    // TODO: implement initState
    homeController = context.read<HomeController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                AppIcons.notificationTopCardP,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActionBarComponent(title: 'Notification Settings'),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              SettingListTile(
                                title: 'Enable Notification',
                                body: 'stay updated with real-time alerts',
                                isChecked: homeController.isEnableNotification,
                                onChanged: (value) {
                                  homeController.setIsEnableNotification =
                                      value!;
                                },
                              ),
                              Divider(color: AppColors.bgGrey),
                              SettingListTile(
                                title: 'Saved Video Alerts',
                                body: 'Stay updated with the latest alerts',
                                isChecked: homeController.isSavedVideo,
                                onChanged: (value) {
                                  homeController.setIsSavedVideo = value!;
                                },
                              ),
                              Divider(color: AppColors.bgGrey),
                              SettingListTile(
                                title: 'Video Alerts',
                                body: 'Stay updated with the latest alerts',
                                isChecked: homeController.isVideoAlerts,
                                onChanged: (value) {
                                  homeController.setIsVideoAlerts = value!;
                                },
                              ),
                              Divider(color: AppColors.bgGrey),
                              SettingListTile(
                                title: 'New shop Alert',
                                body:
                                    'Stay updated with the latest shop alerts',
                                isChecked: homeController.isNewShopAlerts,
                                onChanged: (value) {
                                  homeController.setIsNewShopAlerts = value!;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: HeaderTextPrimary(
                            title: 'General Settings',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),
                        GeneralSettingListTile(
                          image: AppIcons.playVideoP,
                          title: 'Viewed Videos',
                          body: 'videos you have already watched',
                          onTap: () {
                            context.pushNamed(AppRoutes.viewedVideos);
                          },
                        ),
                        SizedBox(height: 15),
                        GeneralSettingListTile(
                          image: AppIcons.deleteBlueP,
                          title: 'Delete Account',
                          body: 'Permanently remove your account',
                          onTap: () {
                            CustomDialogues().showLogoutDialog(
                              context,
                              title: 'Delete Account',
                              isDeleteAccount: true,
                            );
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: CustomFullButton(
          title: 'Save Notification Changes',
          onTap: () {},
        ),
      ),
    );
  }
}

class SettingListTile extends StatelessWidget {
  const SettingListTile({
    super.key,
    required this.title,
    required this.body,
    required this.isChecked,
    this.onChanged,
  });

  final String title, body;
  final bool isChecked;
  final Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: HeaderTextBlack(
        title: title,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 5),
        child: BodyTextHint(
          title: body,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Transform.scale(
        scaleX: 1,
        scaleY: 0.9,
        child: CupertinoSwitch(
          value: isChecked,
          activeTrackColor: GenericColors.darkGreen,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class GeneralSettingListTile extends StatelessWidget {
  const GeneralSettingListTile({
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
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(4),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          leading: Image.asset(image, height: 30, width: 30),
          title: HeaderTextBlack(
            title: title,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          subtitle: BodyTextHint(
            title: body,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
          trailing: SvgPicture.asset(
            AppIcons.arrowForward,
            height: 30,
            width: 30,
          ),
        ),
      ),
    );
  }
}
