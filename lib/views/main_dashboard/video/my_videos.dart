import 'dart:ui';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/main_dashboard/profile/add_shop_detail.dart';
import 'package:mapman/views/main_dashboard/video/components/video_bottom_sheet.dart';
import 'package:mapman/views/main_dashboard/video/single_video_screen.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:video_player/video_player.dart';

class MyVideos extends StatelessWidget {
  const MyVideos({super.key, required this.myVideos});

  final List<VideosData> myVideos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: myVideos.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 100),
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
                    extra: myVideos[index],
                  );
                },
                child: MyVideoContainer(
                  videoUrl:
                      '${ApiRoutes.baseUrl}${myVideos[index].video ?? ''}',
                  views: myVideos[index].views.toString(),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoTitleBlurContainer(
                  isEditIcon: true,
                  videosData: myVideos[index],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// class VideoTitleBlurContainer extends StatelessWidget {
//   const VideoTitleBlurContainer({
//     super.key,
//     this.isWatched = false,
//     this.isEditIcon = false,
//     this.isShopDetail = false,
//     this.isViews = false,
//     required this.videosData,
//   });
//
//   final bool isWatched, isEditIcon, isShopDetail, isViews;
//   final VideosData videosData;
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: const BorderRadius.only(
//         bottomLeft: Radius.circular(6),
//         bottomRight: Radius.circular(6),
//       ),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//         child: Container(
//           height: 48,
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           decoration: BoxDecoration(
//             color: AppColors.darkText.withOpacity(0.2),
//             border: Border(
//               top: BorderSide(
//                 color: AppColors.whiteText.withValues(alpha: .2),
//                 width: .5,
//               ),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Flexible(
//                 child: BodyTextColors(
//                   title: videosData.videoTitle?.capitalize() ?? '',
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.whiteText,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               SizedBox(width: 50),
//               if (videosData.watched == true) ...[
//                 Container(
//                   height: 23,
//                   width: 64,
//                   decoration: BoxDecoration(
//                     color: AppColors.darkText,
//                     borderRadius: BorderRadiusGeometry.circular(20),
//                   ),
//                   child: Center(
//                     child: BodyTextColors(
//                       title: 'Watched',
//                       fontSize: 12,
//                       fontWeight: FontWeight.w400,
//                       color: AppColors.whiteText,
//                     ),
//                   ),
//                 ),
//               ],
//               if (isEditIcon) ...[
//                 GestureDetector(
//                   onTap: () {
//                     VideoBottomSheet().showEditBottomSheet(
//                       context,
//                       videoData: videosData,
//                     );
//                   },
//                   child: Container(
//                     height: 28,
//                     width: 28,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.more_horiz,
//                         color: AppColors.primary,
//                         size: 18,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//               if (isShopDetail) ...[
//                 ShopDetailsButton(
//                   onTap: () {
//                     context.pushNamed(AppRoutes.shopDetail, extra: videosData);
//                   },
//                 ),
//               ],
//
//               if (isViews) ...[
//                 Positioned(
//                   top: 10,
//                   right: 10,
//                   child: Container(
//                     height: 21,
//                     decoration: BoxDecoration(
//                       color: AppColors.darkText,
//                       borderRadius: BorderRadiusGeometry.circular(20),
//                     ),
//                     padding: EdgeInsetsGeometry.symmetric(
//                       horizontal: 5,
//                       vertical: 2,
//                     ),
//                     child: Row(
//                       children: [
//                         SvgPicture.asset(AppIcons.eye),
//                         SizedBox(width: 5),
//                         BodyTextColors(
//                           title: '${videosData.viewCount} views',
//                           fontSize: 10,
//                           fontWeight: FontWeight.w300,
//                           color: AppColors.whiteText,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
            color: AppColors.darkText.withOpacity(0.2),
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

                    if (videosData.watched == true)
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
    required this.videoUrl,
    this.isViews = true,
    this.views,
  });

  final String videoUrl;
  final bool isViews;
  final String? views;

  @override
  State<MyVideoContainer> createState() => _MyVideoContainerState();
}

class _MyVideoContainerState extends State<MyVideoContainer>
    with AutomaticKeepAliveClientMixin {
  late final CachedVideoPlayerPlus _player;

  @override
  void initState() {
    super.initState();

    _player = CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _player.dispose();
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
              child: _player.isInitialized
                  ? VideoPlayer(_player.controller)
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
                      title: '${widget.views} views',
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
              onPressed: () async {
                if (SessionManager.getShopId() != 0) {
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
