import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/model/notification_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late HomeController homeController;

  @override
  void initState() {
    // TODO: implement initState
    homeController = context.read<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNotifications();
    });
    super.initState();
  }

  Future<void> getNotifications() async {
    final response = await homeController.getNotifications();
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
                    child: Builder(
                      builder: (context) {
                        switch (homeController.notificationsData.status) {
                          case Status.INITIAL:
                          case Status.LOADING:
                            return CustomLoadingIndicator();
                          case Status.COMPLETED:
                            final notifications =
                                homeController.notificationsData.data ?? [];
                            if (notifications.isEmpty) {
                              return NoDataText(title: 'No data found');
                            }
                            return ListView.builder(
                              itemCount: notifications.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                return NotificationCard(
                                  notificationsData: notifications[index],
                                );
                              },
                            );
                          case Status.ERROR:
                            return CustomErrorTextWidget(
                              title:
                                  '${homeController.notificationsData.message}',
                            );
                        }
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
  const NotificationCard({super.key, required this.notificationsData});

  final NotificationsData notificationsData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 81,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 12),
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
              color: GenericColors.darkGreen,
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
                child: CustomNetworkImage(
                  imageUrl: notificationsData.msgImage ?? '',
                  isProfile: true,
                  // placeHolderHeight: 20,
                ),
              ),
              title: HeaderTextBlack(
                title: notificationsData.msgTitle?.capitalize() ?? '',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 5),
                child: BodyTextHint(
                  title: notificationsData.msgDesc?.capitalize() ?? '',
                  fontSize: 12,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 3),
                      HeaderTextPrimary(
                        title: notificationsData.createdAt ?? '',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
