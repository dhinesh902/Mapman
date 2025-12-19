import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/components/video_Dialogue.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:provider/provider.dart';

class VideoBottomSheet {
  Future<void> showEditBottomSheet(
    BuildContext context, {
    required VideosData videoData,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.9,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),

                  /// Drag Handle
                  Container(
                    height: 4,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Edit Video
                  VideoEditListTile(
                    icon: AppIcons.editP,
                    title: 'Edit Video Details',
                    body: 'Update and manage key information',
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      Future.microtask(() {
                        if (!context.mounted) return;
                        context.pushNamed(
                          AppRoutes.uploadVideo,
                          extra: videoData,
                        );
                      });
                    },
                  ),

                  const Divider(height: 1, color: AppColors.bgGrey),

                  /// Replace Video
                  VideoEditListTile(
                    icon: AppIcons.videoClipP,
                    title: 'Replace Video',
                    body: 'Click to replace the existing video',
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      Future.microtask(() {
                        if (!context.mounted) return;
                        context.pushNamed(
                          AppRoutes.replaceVideo,
                          extra: videoData,
                        );
                      });
                    },
                  ),

                  const Divider(height: 1, color: AppColors.bgGrey),

                  /// Delete Video
                  VideoEditListTile(
                    icon: AppIcons.deleteP,
                    title: 'Delete Video',
                    body: 'Delete this video permanently',
                    onTap: () {
                      VideoDialogues().showVideoDeleteDialogue(
                        context,
                        onTap: () async {
                          Navigator.of(context).pop();
                          CustomDialogues.showLoadingDialogue(context);

                          final controller = context.read<VideoController>();

                          final response = await controller.deleteMyVideo(
                            videoId: videoData.id ?? 0,
                          );

                          if (!context.mounted) return;
                          Navigator.of(context).pop();

                          Future.microtask(() {
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          });

                          await controller.getMyVideos();
                          if (!context.mounted) return;
                          if (response.status == Status.COMPLETED) {
                            CustomDialogues().showDeleteDialog(context);
                          } else {
                            ExceptionHandler.handleUiException(
                              context: context,
                              status: response.status,
                              message: response.message,
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
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
