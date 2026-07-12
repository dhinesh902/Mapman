import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/main_dashboard/profile/add_shop_detail.dart';
import 'package:mapman/views/main_dashboard/video/components/video_bottom_sheet.dart';
import 'package:mapman/views/main_dashboard/video/single_video_screen.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mapman/routes/api_routes.dart';

class _MyVideosBlockData {
  final int? index0;
  final int? index1;
  final int? index2;
  final int? index3;

  _MyVideosBlockData({this.index0, this.index1, this.index2, this.index3});
}

class MyVideos extends StatelessWidget {
  const MyVideos({super.key, required this.myVideos});

  final List<VideosData> myVideos;

  @override
  Widget build(BuildContext context) {
    if (myVideos.isEmpty) {
      return const Center(
        child: BodyTextColors(
          title: 'No videos uploaded yet',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.whiteText,
        ),
      );
    }

    final totalCount = myVideos.length;
    final List<_MyVideosBlockData> blocks = [];
    for (int i = 0; i < totalCount; i += 4) {
      blocks.add(
        _MyVideosBlockData(
          index0: i,
          index1: i + 1 < totalCount ? i + 1 : null,
          index2: i + 2 < totalCount ? i + 2 : null,
          index3: i + 3 < totalCount ? i + 3 : null,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
      itemCount: blocks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final block = blocks[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              child: Column(
                children: [
                  if (block.index0 != null) ...[
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: _buildTile(context, block.index0!),
                    ),
                  ],
                  if (block.index3 != null) ...[
                    const SizedBox(height: 8),
                    AspectRatio(
                      aspectRatio: 2 / 2.2,
                      child: _buildTile(context, block.index3!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right Column
            Expanded(
              child: Column(
                children: [
                  if (block.index1 != null) ...[
                    AspectRatio(
                      aspectRatio: 2 / 2.2,
                      child: _buildTile(context, block.index1!),
                    ),
                  ],
                  if (block.index2 != null) ...[
                    const SizedBox(height: 8),
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: _buildTile(context, block.index2!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, int index) {
    final video = myVideos[index];
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.singleVideoScreen,
          extra: {
            Keys.videosData: myVideos,
            Keys.isMyVideos: true,
            Keys.initialIndex: index,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            children: [
              Positioned.fill(
                child: MyVideoContainer(
                  thumbnail: video.thumbnail ?? '',
                  views: video.views.toString(),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoTitleBlurContainer(
                  isEditIcon: true,
                  videosData: video,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoTitleBlurContainer extends StatelessWidget {
  const VideoTitleBlurContainer({
    super.key,
    this.isWatched = false,
    this.isEditIcon = false,
    this.isShopDetail = false,
    this.isViews = false,
    required this.videosData,
  });

  final bool isWatched, isEditIcon, isShopDetail, isViews;
  final VideosData videosData;

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
          decoration: BoxDecoration(
            color: AppColors.darkText.withValues(alpha: 0.2),
            border: Border(
              top: BorderSide(
                color: AppColors.whiteText.withValues(alpha: .2),
                width: .5,
              ),
            ),
          ),

          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: BodyTextColors(
                        title: videosData.videoTitle?.capitalize() ?? '',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (videosData.watched == true && isWatched)
                      Container(
                        height: 23,
                        width: 64,
                        decoration: BoxDecoration(
                          color: AppColors.darkText,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: BodyTextColors(
                            title: 'Watched',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteText,
                          ),
                        ),
                      ),

                    if (isEditIcon)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () {
                            VideoBottomSheet().showEditBottomSheet(
                              context,
                              videoData: videosData,
                            );
                          },
                          child: Container(
                            height: 28,
                            width: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.more_horiz,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (isShopDetail)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ShopDetailsButton(
                          onTap: () {
                            context.pushNamed(
                              AppRoutes.shopDetail,
                              extra: videosData.shopId,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              if (isViews)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    height: 21,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkText,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(AppIcons.eye),
                        const SizedBox(width: 5),
                        BodyTextColors(
                          title: '${videosData.viewCount} views',
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: AppColors.whiteText,
                        ),
                      ],
                    ),
                  ),
                ),
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
    required this.thumbnail,
    this.isViews = true,
    this.isAllVideos = false,
    this.views,
    this.isShowPlayButton = true,
  });

  final String thumbnail;
  final bool isViews, isAllVideos;
  final String? views;
  final bool isShowPlayButton;

  @override
  State<MyVideoContainer> createState() => _MyVideoContainerState();
}

class _MyVideoContainerState extends State<MyVideoContainer> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isAllVideos ? 0 : 11),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2D32), Color(0xFF131417)],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.isAllVideos ? 0 : 11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// Thumbnail from API (Image URL)
              if (widget.thumbnail.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: widget.thumbnail.startsWith('http')
                        ? widget.thumbnail
                        : '${ApiRoutes.baseUrl}${widget.thumbnail}',
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              /// Dark overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.12),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.28),
                      ],
                    ),
                  ),
                ),
              ),

              /// Play button
              if (widget.isShowPlayButton)
                const Center(
                  child: IgnorePointer(
                    child: VideoPausePlayGradientCircleContainer(),
                  ),
                ),

              /// Views
              if (widget.isViews &&
                  widget.views != null &&
                  widget.views!.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: RepaintBoundary(
                    child: Container(
                      height: 21,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkText.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppIcons.eye,
                            height: 10,
                            width: 10,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          BodyTextColors(
                            title: '${widget.views} views',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
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
              onPressed: () async {
                final shopId = SessionManager.getShopId();
                if (shopId != null && shopId != 0) {
                  context.pushNamed(AppRoutes.uploadVideo, extra: VideosData());
                } else {
                  await showAddShopDetail(context);
                }
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
