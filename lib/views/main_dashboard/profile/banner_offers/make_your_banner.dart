import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';

class MakeYourOwnBanner extends StatefulWidget {
  const MakeYourOwnBanner({super.key});

  @override
  State<MakeYourOwnBanner> createState() => _MakeYourOwnBannerState();
}

class _MakeYourOwnBannerState extends State<MakeYourOwnBanner> {
  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: "Make Your Own Banner"),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          children: [
            MakeYourBannerCard(
              icon: AppIcons.bannerUploadP,
              title: "Upload Image",
              subTitle: "Use your own photo as the banner",
              onTap: () {
                context.pushNamed(AppRoutes.uploadMakeYourOwnBanner);
              },
            ),
            SizedBox(height: 20),
            MakeYourBannerCard(
              icon: AppIcons.bannerCreateP,
              title: "Create with Text",
              subTitle: "Give your input we design it",
              onTap: () {
                context.pushNamed(AppRoutes.createMakeYourOwnBanner);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MakeYourBannerCard extends StatelessWidget {
  const MakeYourBannerCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.onTap,
  });

  final String icon, title, subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.whiteText,
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: GenericColors.bannerBlue2.withValues(alpha: .2),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Image.asset(
                icon,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderTextPrimary(
                    title: title,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title: subTitle,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
