import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_image.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
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
                children: [
                  ActionBarComponent(
                    title: 'Notifications',
                    action: IconButton(
                      onPressed: () {
                        context.pushNamed(AppRoutes.notificationSettings);
                      },
                      icon: Icon(
                        Icons.settings,
                        size: 24,
                        color: AppColors.whiteText,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 15,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return NotificationCard(isTime: index % 2 == 0);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.isTime});

  final bool isTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 81,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(6), // FIXED
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 69,
            decoration: BoxDecoration(
              color: isTime ? GenericColors.darkGreen : GenericColors.darkRed,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.only(right: 10, left: 20),
              leading: Container(
                height: 46,
                width: 46,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.hardEdge,
                child: const CustomNetworkImage(
                  imageUrl:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQkAJEkJQ1WumU0hXNpXdgBt9NUKc0QDVIiaw&s',
                  isProfile: true,
                  // placeHolderHeight: 20,
                ),
              ),
              title: const HeaderTextBlack(
                title: 'Nithyakumar',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 5),
                child: BodyTextHint(
                  title: 'Viewed your shop details',
                  fontSize: 12,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: isTime
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Icon(
                              CupertinoIcons.clock,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 3),
                            HeaderTextPrimary(
                              title: '4 Hrs Ago',
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                      ],
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
