import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';

class VideoBottomSheet {
  Future<dynamic> showEditBottomSheet(
    BuildContext context, {
    required VideosData videoData,
  }) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .9,
            ),
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(height: 4, color: AppColors.darkGrey, width: 200),
                  VideoEditListTile(
                    icon: AppIcons.editP,
                    title: 'Edit Video Details',
                    body: 'Update and manage key information',
                    onTap: () {
                      Navigator.pop(context);
                      Future.microtask(() {
                        if (!context.mounted) return;
                        context.pushNamed(
                          AppRoutes.uploadVideo,
                          extra: videoData,
                        );
                      });
                    },
                  ),
                  Divider(height: 1, color: AppColors.bgGrey),
                  VideoEditListTile(
                    icon: AppIcons.videoClipP,
                    title: 'Replace Video',
                    body: 'Click to replace to existing video',
                    onTap: () {
                      Navigator.pop(context);
                      Future.microtask(() {
                        if (!context.mounted) return;
                        context.pushNamed(
                          AppRoutes.replaceVideo,
                          extra: videoData,
                        );
                      });
                    },
                  ),
                  Divider(height: 1, color: AppColors.bgGrey),
                  VideoEditListTile(
                    icon: AppIcons.deleteP,
                    title: 'Delete Video',
                    body: 'Delete this video permanently',
                    onTap: () {
                      CustomDialogues().showDeleteDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class VideoEditListTile extends StatelessWidget {
  const VideoEditListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String icon, title, body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsetsGeometry.only(left: 30, right: 30),
      leading: Image.asset(icon, height: 40, width: 40),
      title: HeaderTextBlack(
        title: title,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      subtitle: BodyTextHint(
        title: body,
        fontSize: 12,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
