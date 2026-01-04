import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/model/notification_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late HomeController homeController;

  late int _initialEnableNotification;
  late int _initialVideoAlert;
  late int _initialNewShopAlert;

  @override
  void initState() {
    // TODO: implement initState
    homeController = context.read<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNotificationPreference();
    });
    super.initState();
  }

  Future<void> addNotificationPreference() async {
    final response = await homeController.addNotificationPreference(
      preference: homeController.preferenceData,
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      await CustomDialogues.showSuccessDialog(
        context,
        title: 'SuccessFully Updated!',
        body: 'Your notification settings updated successfully!',
      );
      if (!mounted) return;
      context.pop();
    } else {
      if (!mounted) return;
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  Future<void> getNotificationPreference() async {
    final response = await homeController.getNotificationPreference();
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      final preference = response.data;
      homeController.initPreferences(
        preference ?? NotificationPreferenceData(),
      );

      ///initial data
      _initialEnableNotification = preference?.enableNotifications ?? 0;
      _initialVideoAlert = preference?.newVideo ?? 0;
      _initialNewShopAlert = preference?.newShop ?? 0;
    } else {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  bool hasChanges() {
    final preferenceData = homeController.preferenceData;
    if (preferenceData.enableNotifications != _initialEnableNotification) {
      return true;
    }
    if (preferenceData.newVideo != _initialVideoAlert) return true;
    if (preferenceData.newShop != _initialNewShopAlert) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (!hasChanges()) {
          Navigator.pop(context);
          return;
        }

        await CustomDialogues().showUpdateReviewDialogue(
          context,
          onTap: () async {
            await addNotificationPreference();
          },
        );
      },
      child: Scaffold(
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
                    ActionBarComponent(
                      title: 'Notification Settings',
                      onTap: () async {
                        if (!hasChanges()) {
                          Navigator.pop(context);
                          return;
                        }

                        await CustomDialogues().showUpdateReviewDialogue(
                          context,
                          onTap: () async {
                            await addNotificationPreference();
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final apiStatus =
                              homeController.notificationPreferenceData.status;
                          final preferenceData = homeController.preferenceData;

                          if (apiStatus == Status.INITIAL ||
                              apiStatus == Status.LOADING) {
                            return CustomLoadingIndicator();
                          }

                          if (apiStatus == Status.ERROR) {
                            return CustomErrorTextWidget(
                              title:
                                  '${homeController.notificationPreferenceData.message}',
                            );
                          }

                          return ListView(
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
                                      body:
                                          'Stay updated with real-time alerts',
                                      isChecked:
                                          (preferenceData.enableNotifications ??
                                              0) ==
                                          1,
                                      onChanged: (value) {
                                        homeController.updatePreferences(
                                          enableNotifications: value ? 1 : 0,
                                          savedVideo: value ? null : 0,
                                          newVideo: value ? null : 0,
                                          newShop: value ? null : 0,
                                        );
                                      },
                                    ),

                                    Divider(color: AppColors.bgGrey),

                                    // SettingListTile(
                                    //   title: 'Saved Video Alerts',
                                    //   body:
                                    //       'Stay updated with the latest alerts',
                                    //   isChecked:
                                    //       (preferenceData.savedVideo ?? 0) == 1,
                                    //   enabled: (preferenceData.enableNotifications ?? 0) == 1,
                                    //   onChanged: (value) {
                                    //     homeController.updatePreferences(
                                    //       savedVideo: value ? 1 : 0,
                                    //     );
                                    //   },
                                    // ),
                                    //
                                    // Divider(color: AppColors.bgGrey),
                                    SettingListTile(
                                      title: 'Video Alerts',
                                      body:
                                          'Stay updated with the latest alerts',
                                      isChecked:
                                          (preferenceData.newVideo ?? 0) == 1,
                                      enabled:
                                          (preferenceData.enableNotifications ??
                                              0) ==
                                          1,
                                      onChanged: (value) {
                                        homeController.updatePreferences(
                                          newVideo: value ? 1 : 0,
                                        );
                                      },
                                    ),

                                    Divider(color: AppColors.bgGrey),

                                    SettingListTile(
                                      title: 'New Shop Alert',
                                      body:
                                          'Stay updated with the latest shop alerts',
                                      isChecked:
                                          (preferenceData.newShop ?? 0) == 1,
                                      enabled:
                                          (preferenceData.enableNotifications ??
                                              0) ==
                                          1,
                                      onChanged: (value) {
                                        homeController.updatePreferences(
                                          newShop: value ? 1 : 0,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            homeController.notificationPreferenceData.status == Status.LOADING
            ? SizedBox.shrink()
            : SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (homeController.apiResponse.status == Status.LOADING)
                      ButtonProgressBar()
                    else
                      CustomFullButton(
                        title: 'Save Notification Changes',
                        onTap: () async {
                          await addNotificationPreference();
                        },
                      ),
                  ],
                ),
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
    required this.onChanged,
    this.enabled = true,
  });

  final String title, body;
  final bool isChecked;
  final bool enabled;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
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
            onChanged: enabled ? onChanged : null,
          ),
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
