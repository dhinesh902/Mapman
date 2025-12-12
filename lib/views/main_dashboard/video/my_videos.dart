import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/video/components/video_bottom_sheet.dart';
import 'package:mapman/views/main_dashboard/video/single_video_screen.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:video_player/video_player.dart';

class MyVideos extends StatelessWidget {
  const MyVideos({super.key, required this.videoUrls});

  final List<String> videoUrls;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: videoUrls.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        return Container(
          height: 174,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  context.pushNamed(
                    AppRoutes.singleVideoScreen,
                    extra: videoUrls[index],
                  );
                },
                child: MyVideoContainer(videoUrl: videoUrls[index]),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoTitleBlurContainer(isEditIcon: true),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VideoTitleBlurContainer extends StatelessWidget {
  const VideoTitleBlurContainer({
    super.key,
    this.isWatched = false,
    this.isEditIcon = false,
    this.isShopDetail = false,
  });

  final bool isWatched;
  final bool isEditIcon;
  final bool isShopDetail;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(6),
        bottomRight: Radius.circular(6),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: AppColors.darkText.withOpacity(0.2),
            border: Border(
              top: BorderSide(
                color: AppColors.whiteText.withValues(alpha: .2),
                width: .5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyTextColors(
                title: "Video Title",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteText,
              ),
              if (isWatched) ...[
                Container(
                  height: 23,
                  width: 64,
                  decoration: BoxDecoration(
                    color: AppColors.darkText,
                    borderRadius: BorderRadiusGeometry.circular(20),
                  ),
                  child: Center(
                    child: BodyTextColors(
                      title: 'Watched',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.whiteText,
                    ),
                  ),
                ),
              ],
              if (isEditIcon) ...[
                GestureDetector(
                  onTap: () {
                    VideoBottomSheet().showEditBottomSheet(context);
                  },
                  child: Container(
                    height: 28,
                    width: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.more_horiz,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
              if (isShopDetail) ...[
                ShopDetailsButton(
                  onTap: () {
                    context.pushNamed(AppRoutes.viewedVideosShopDetail);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MyVideoContainer extends StatefulWidget {
  const MyVideoContainer({
    super.key,
    required this.videoUrl,
    this.isViews = true,
  });

  final String videoUrl;
  final bool isViews;

  @override
  State<MyVideoContainer> createState() => _MyVideoContainerState();
}

class _MyVideoContainerState extends State<MyVideoContainer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: 174,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(6),
              child: _controller.value.isInitialized
                  ? VideoPlayer(_controller)
                  : Container(color: AppColors.bgGrey),
            ),
          ),
          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: Center(child: VideoPausePlayGradientCircleContainer()),
          ),
          if (widget.isViews) ...[
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                height: 21,
                decoration: BoxDecoration(
                  color: AppColors.darkText,
                  borderRadius: BorderRadiusGeometry.circular(20),
                ),
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(AppIcons.eye),
                    SizedBox(width: 5),
                    BodyTextColors(
                      title: '100k views',
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: AppColors.whiteText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class NoVideoContainer extends StatelessWidget {
  const NoVideoContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadiusGeometry.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppIcons.videoClipP,
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            BodyTextHint(
              title: 'No videos are here',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            TextButton(
              onPressed: () {
                context.pushNamed(AppRoutes.uploadVideo);
              },
              child: HeaderTextPrimary(
                title: 'Upload video',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                textDecoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
