import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class UploadVideo extends StatefulWidget {
  const UploadVideo({super.key, required this.videosData});

  final VideosData videosData;

  @override
  State<UploadVideo> createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  late VideoController videoController;

  final ValueNotifier<File?> videoNotifier = ValueNotifier<File?>(null);
  final ValueNotifier<bool> videoValidator = ValueNotifier<bool>(false);

  final formKey = GlobalKey<FormState>();
  late TextEditingController videoTitleController,
      videoDescriptionController,
      categoryController,
      shopNameController;

  @override
  void initState() {
    // TODO: implement initState
    videoController = context.read<VideoController>();
    videoTitleController = TextEditingController();
    videoDescriptionController = TextEditingController();
    categoryController = TextEditingController(
      text: SessionManager.getShopCategory()?.capitalize() ?? '',
    );
    shopNameController = TextEditingController(
      text: SessionManager.getShopName()?.capitalize() ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoController.setVideoFileSize = false;
      getVideoDetails();
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    videoNotifier.dispose();
    videoValidator.dispose();
    videoTitleController.dispose();
    videoDescriptionController.dispose();
    shopNameController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  void getVideoDetails() {
    final videoDetail = widget.videosData;
    if (videoDetail.videoTitle != null) {
      videoTitleController.text = videoDetail.videoTitle ?? '';
      videoDescriptionController.text = videoDetail.description ?? '';
    }
  }

  Future<void> uploadVideo() async {
    final VideosData videosData = VideosData(
      videoTitle: videoTitleController.text.trim(),
      shopName: shopNameController.text.trim(),
      category: categoryController.text.trim().toLowerCase(),
      description: videoDescriptionController.text.trim(),
    );
    final response = await videoController.uploadMyVideos(
      video: videoNotifier.value!,
      videoData: videosData,
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

  Future<void> updateMyVideoDetail() async {
    final VideosData videosData = VideosData(
      id: widget.videosData.id,
      shopId: widget.videosData.shopId,
      videoTitle: videoTitleController.text.trim(),
      shopName: shopNameController.text.trim(),
      category: categoryController.text.trim(),
      description: videoDescriptionController.text.trim(),
    );
    final response = await videoController.updateMyVideo(
      videosData: videosData,
    );
    if (response.status == Status.COMPLETED) {
      if (!mounted) return;
      await CustomDialogues.showSuccessDialog(
        context,
        title: 'SuccessFully Updated!',
        body: 'Your shop video detail successfully!',
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
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Video Upload'),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              SizedBox(height: 10),
              ValueListenableBuilder(
                valueListenable: videoNotifier,
                builder: (context, file, _) {
                  if (widget.videosData.video != null) {
                    return Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: GenericColors.placeHolderGrey,
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      child: Center(
                        child: UploadVideoUrlContainer(
                          videoUrl:
                              '${ApiRoutes.baseUrl}${widget.videosData.video ?? ''}',
                        ),
                      ),
                    );
                  }
                  return EmptyVideoUploadContainer(
                    file: file,
                    onTap: () async {
                      await pickVideo();
                    },
                  );
                },
              ),
              SizedBox(height: 5),

              ValueListenableBuilder(
                valueListenable: videoValidator,
                builder: (context, hasError, _) {
                  if (!hasError) return const SizedBox.shrink();
                  return Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: BodyTextColors(
                      title: 'Please select video',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.red.shade900,
                    ),
                  );
                },
              ),

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
              SizedBox(height: 25),
              CustomTextField(
                title: 'Video Title',
                controller: videoTitleController,
                hintText: "Enter video title",
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter video title";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomTextField(
                title: 'Description',
                controller: videoDescriptionController,
                hintText: "Enter video description",
                inputAction: TextInputAction.done,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter video description";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomTextField(
                title: 'Shop Name',
                controller: shopNameController,
                hintText: "Enter shop name",
                inputAction: TextInputAction.done,
                isReadOnly: true,
              ),

              SizedBox(height: 15),
              CustomTextField(
                title: 'Category',
                controller: categoryController,
                hintText: "Enter shop name",
                inputAction: TextInputAction.done,
                isReadOnly: true,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (videoController.response.status == Status.LOADING)
              ButtonProgressBar()
            else
              CustomFullButton(
                title: 'Upload Video',
                onTap: () async {
                  if (widget.videosData.videoTitle != null) {
                    await updateMyVideoDetail();
                    return;
                  } else {
                    final bool isFormValid =
                        formKey.currentState?.validate() ?? false;
                    final bool hasVideo = videoNotifier.value != null;
                    videoValidator.value = !hasVideo;
                    if (isFormValid && hasVideo) {
                      await uploadVideo();
                    }
                  }
                },
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
        videoValidator.value = false;
      }
    }
  }
}

class EmptyVideoUploadContainer extends StatelessWidget {
  const EmptyVideoUploadContainer({
    super.key,
    required this.file,
    required this.onTap,
  });

  final File? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: GenericColors.placeHolderGrey,
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        child: Center(
          child: file != null
              ? UploadVideoFileContainer(
                  key: ValueKey(file!.path),
                  videoFile: file!,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppIcons.videoUploadP,
                      height: 60,
                      width: 60,
                      color: AppColors.darkGrey,
                    ),
                    SizedBox(height: 15),
                    BodyTextHint(
                      title: 'Upload Video for your shop',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class UploadVideoFileContainer extends StatefulWidget {
  const UploadVideoFileContainer({super.key, required this.videoFile});

  final File videoFile;

  @override
  State<UploadVideoFileContainer> createState() =>
      _UploadVideoFileContainerState();
}

class _UploadVideoFileContainerState extends State<UploadVideoFileContainer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        Positioned.fill(
          child: Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UploadVideoUrlContainer extends StatefulWidget {
  const UploadVideoUrlContainer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<UploadVideoUrlContainer> createState() =>
      _UploadVideoUrlContainerState();
}

class _UploadVideoUrlContainerState extends State<UploadVideoUrlContainer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(10),
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: InkWell(
              onTap: () {
                if (mounted) {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                }
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppColors.scaffoldBackground,
                ),
                alignment: Alignment.center,
                child: Container(
                  color: Colors.transparent,
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_sharp
                        : Icons.play_arrow,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
