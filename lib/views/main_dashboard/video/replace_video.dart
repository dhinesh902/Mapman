import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/video/upload_video.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:provider/provider.dart';

class ReplaceVideo extends StatefulWidget {
  const ReplaceVideo({super.key});

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

  @override
  Widget build(BuildContext context) {
    videoController = context.watch<VideoController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Replace Video Details'),
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
                        return UploadVideoContainer(videoFile: file);
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppIcons.videoUploadP,
                              height: 80,
                              width: 80,
                              color: AppColors.darkGrey,
                            ),
                            SizedBox(height: 15),
                            BodyTextHint(
                              title: 'Upload Video for your shop',
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ],
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
            CustomFullButton(
              title: 'Replace  Video',
              isDialogue: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      int fileSizeInBytes = await pickedFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 10.00) {
        videoController.setVideoFileSize = true;
      } else {
        videoController.setVideoFileSize = false;
        videoNotifier.value = File(pickedFile.path);
      }
    }
  }
}
