import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/profile_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/main_dashboard/home/home.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late ProfileController profileController;

  @override
  void initState() {
    // TODO: implement initState
    profileController = context.read<ProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getProfile();
    });
    super.initState();
  }

  Future<void> getProfile() async {
    final response = await profileController.getProfile();
    if (!mounted) return;
    if (response.status == Status.ERROR) {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    profileController = context.watch<ProfileController>();
    final shopId = SessionManager.getShopId();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Builder(
        builder: (context) {
          switch (profileController.profileData.status) {
            case Status.INITIAL:
              return CustomLoadingIndicator();
            case Status.LOADING:
              return CustomLoadingIndicator();
            case Status.COMPLETED:
              final profileData =
                  profileController.profileData.data ?? ProfileData();
              return Column(
                children: [
                  const ProfileTopCard(),
                  const SizedBox(height: 20),
                  ProfileImage(profileData: profileData),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 30),
                      shrinkWrap: true,
                      children: [
                        ProfileListTile(
                          image: AppIcons.personP,
                          title: 'Profile Details',
                          body: 'View your details',
                          onTap: () {
                            context.pushNamed(
                              AppRoutes.editProfile,
                              extra: profileData,
                            );
                          },
                        ),
                        SizedBox(height: 15),
                        ProfileListTile(
                          image: AppIcons.shopP,
                          title: 'Shop Details',
                          body: 'Edit shop details',
                          onTap: () {
                            context.pushNamed(AppRoutes.addShopDetail);
                          },
                        ),
                        if (shopId != 0) ...[
                          SizedBox(height: 15),
                          ProfileListTile(
                            image: AppIcons.analyticsP,
                            title: 'Shop Analytics',
                            body: 'Shop Metrics',
                            onTap: () {
                              context.pushNamed(AppRoutes.analytics);
                            },
                          ),
                        ],
                        SizedBox(height: 15),
                        ProfileListTile(
                          image: AppIcons.chatP,
                          title: 'Chat',
                          body: 'Chat with your shop people',
                          onTap: () {
                            context.pushNamed(AppRoutes.chats);
                          },
                        ),
                        SizedBox(height: 15),
                        ProfileListTile(
                          image: AppIcons.helpP,
                          title: 'Help & Support',
                          body: '24×7 Customer Support',
                          onTap: () {
                            context.pushNamed(AppRoutes.helpAndSupport);
                          },
                        ),
                        SizedBox(height: 15),
                        ProfileListTile(
                          image: AppIcons.logoutP,
                          title: 'Logout',
                          body: 'Close the Current Profile',
                          onTap: () {
                            CustomDialogues().showLogoutDialog(
                              context,
                              title: 'Sign out',
                              isDeleteAccount: false,
                            );
                          },
                        ),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              );
            case Status.ERROR:
              return CustomErrorTextWidget(
                title: '${profileController.profileData.message}',
              );
          }
        },
      ),
    );
  }
}

class ProfileTopCard extends StatelessWidget {
  const ProfileTopCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      title: const HeaderTextBlack(
        title: 'Your Profile',
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      subtitle: const Padding(
        padding: EdgeInsets.only(top: 5),
        child: BodyTextHint(
          title: 'Manage your profile now!!',
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleContainer(
            onTap: () {
              context.pushNamed(AppRoutes.savedVideos);
            },
            child: Image.asset(AppIcons.bookmarkP, height: 30),
          ),
          const SizedBox(width: 15),
          CircleContainer(
            onTap: () {
              context.pushNamed(AppRoutes.notifications);
            },
            child: SvgPicture.asset(AppIcons.notification),
          ),
        ],
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key, required this.profileData});

  final ProfileData profileData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 125,
          width: 160,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.hardEdge,
          child: CustomNetworkImage(imageUrl: profileData.profilePic ?? ''),
        ),
        const SizedBox(height: 10),
        HeaderTextBlack(
          title: profileData.userName?.capitalize() ?? 'Profile Name',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        const BodyTextHint(
          title: 'Update your profile picture & details here',
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
      ],
    );
  }
}

class ProfileListTile extends StatelessWidget {
  const ProfileListTile({
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Image.asset(image, height: 30, width: 30, fit: BoxFit.contain),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderTextBlack(
                    title: title,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 5),
                  BodyTextHint(
                    title: body,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SvgPicture.asset(AppIcons.arrowForward),
          ],
        ),
      ),
    );
  }
}
