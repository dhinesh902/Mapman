import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/upload_video.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class ReplaceVideo extends StatefulWidget {
  const ReplaceVideo({super.key, required this.videosData});

  final VideosData videosData;

  @override
  State<ReplaceVideo> createState() => _ReplaceVideoState();
}

class _ReplaceVideoState extends State<ReplaceVideo> {
  late VideoController videoController;
  final ValueNotifier<File?> videoNotifier = ValueNotifier(null);

  @override
  void initState() {
    // TODO: implement initState
    videoController = context.read<VideoController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoController.setVideoFileSize = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    videoNotifier.dispose();
    super.dispose();
  }

  Future<void> replaceMyVideo() async {
    final response = await videoController.replaceMyVideo(
      video: videoNotifier.value!,
      videoId: widget.videosData.id ?? 0,
    );
    if (response.status == Status.COMPLETED) {
      if (!mounted) return;
      await CustomDialogues.showSuccessDialog(
        context,
        title: 'SuccessFully Updated!',
        body: 'Your shop video updated successfully!',
      );
      if (!mounted) return;
      context.pop();
      await videoController.getMyVideos();
    } else {
      if (!mounted) return;
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    videoController = context.watch<VideoController>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (videoNotifier.value == null) {
          Navigator.pop(context);
          return;
        }

        await CustomDialogues().showUpdateReviewDialogue(
          context,
          onTap: () async {
            await replaceMyVideo();
          },
        );
      },
      child: CustomSafeArea(
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackgroundDark,
          appBar: ActionBar(
            title: 'Replace Video Details',
            onTap: () async {
              if (videoNotifier.value == null) {
                Navigator.pop(context);
                return;
              }

              await CustomDialogues().showUpdateReviewDialogue(
                context,
                onTap: () async {
                  await replaceMyVideo();
                },
              );
            },
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
            children: [
              GestureDetector(
                onTap: () async {
                  await pickVideo();
                },
                child: Container(
                  height: 187,
                  decoration: BoxDecoration(
                    color: GenericColors.placeHolderGrey,
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                  child: Center(
                    child: ValueListenableBuilder(
                      valueListenable: videoNotifier,
                      builder: (context, file, _) {
                        if (file != null) {
                          return UploadVideoFileContainer(
                            key: ValueKey(file.path),
                            videoFile: file,
                          );
                        } else {
                          return UploadVideoUrlContainer(
                            videoUrl:
                                '${ApiRoutes.baseUrl}${widget.videosData.video ?? ''}',
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              if (videoController.isVideoFileSize) ...[
                Align(
                  alignment: AlignmentGeometry.centerRight,
                  child: BodyTextColors(
                    title: 'Note Video size Less than 10MB.',
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: GenericColors.darkRed,
                  ),
                ),
              ],
              SizedBox(height: 40),
              if (videoController.response.status == Status.LOADING) ...[
                ButtonProgressBar(),
              ] else ...[
                CustomFullButton(
                  title: 'Replace  Video',
                  isDialogue: true,
                  onTap: () async {
                    if (videoNotifier.value == null) {
                      CustomToast.show(
                        context,
                        title: 'Please select upload video',
                        isError: true,
                      );
                      return;
                    } else {
                      await replaceMyVideo();
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickVideo() async {
    final XFile? pickedFile = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    final int size = await pickedFile.length();
    final double sizeMB = size / (1024 * 1024);
    if (sizeMB > 10) {
      videoController.setVideoFileSize = true;
      return;
    }
    videoNotifier.value = File(pickedFile.path);
  }
}
