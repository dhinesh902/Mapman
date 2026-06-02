import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/model/shop_detail_model.dart';
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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:mapman/utils/storage/video_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class MyVideos extends StatefulWidget {
  const MyVideos({super.key, required this.myVideos});

  final List<VideosData> myVideos;

  @override
  State<MyVideos> createState() => _MyVideosState();
}

class _MyVideosState extends State<MyVideos> {
  ShopDetailData? selectedShop;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, profileCtrl, _) {
        final shops = profileCtrl.shopListData.data ?? [];
        final filteredVideos = selectedShop != null
            ? widget.myVideos
                  .where((v) => v.shopName == selectedShop?.shopName)
                  .toList()
            : widget.myVideos;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
          child: Column(
            children: [
              if (shops.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF4FFF5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withValues(alpha: .18),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: .10),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<ShopDetailData>(
                        isExpanded: true,
                        hint: Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              color: const Color(0xFF4CAF50),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Select shop to filter videos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkText.withValues(
                                    alpha: .7,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items: shops.map((item) {
                          return DropdownMenuItem<ShopDetailData>(
                            value: item,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.store,
                                  color: const Color(0xFF4CAF50),
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.shopName?.capitalize() ?? '',
                                    style: AppTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkText,
                                    ).textStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        value: selectedShop,
                        onChanged: (value) {
                          if (mounted) setState(() => selectedShop = value);
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 55,
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          elevation: 0,
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down_rounded),
                          iconSize: 24,
                          iconEnabledColor: AppColors.darkText,
                          iconDisabledColor: AppColors.darkText.withValues(
                            alpha: .5,
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(
                                0xFF4CAF50,
                              ).withValues(alpha: .18),
                              width: 2,
                            ),
                          ),
                          offset: const Offset(0, -5),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              if (filteredVideos.isEmpty)
                const NoVideoContainer()
              else
                StaggeredGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(filteredVideos.length, (index) {
                    final video = filteredVideos[index];

                    final pattern = index % 4;

                    int crossAxis = 2;
                    double mainAxis = 2;

                    switch (pattern) {
                      case 0:
                        crossAxis = 2;
                        mainAxis = 3;
                        break;
                      case 1:
                        crossAxis = 2;
                        mainAxis = 2.2;
                        break;
                      case 2:
                        crossAxis = 2;
                        mainAxis = 3;
                        break;
                      case 3:
                        crossAxis = 2;
                        mainAxis = 2.2;
                        break;
                    }

                    return StaggeredGridTile.count(
                      crossAxisCellCount: crossAxis,
                      mainAxisCellCount: mainAxis,
                      child: GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.singleVideoScreen,
                            extra: {
                              Keys.videosData: filteredVideos,
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
                                MyVideoContainer(
                                  videoUrl: video.video ?? '',
                                  views: video.views.toString(),
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
                      ),
                    );
                  }),
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
    required this.videoUrl,
    this.isViews = true,
    this.isAllVideos = false,
    this.views,
    this.isShowPlayButton = true,
  });

  final String videoUrl;
  final bool isViews, isAllVideos;
  final String? views;
  final bool isShowPlayButton;

  @override
  State<MyVideoContainer> createState() => _MyVideoContainerState();
}

class _MyVideoContainerState extends State<MyVideoContainer> {
  Uint8List? _thumbnailData;
  bool _isLoading = false;

  // Static map deduplicates concurrent thumbnail requests for the same URL.
  // Entries are pruned as soon as the future resolves to prevent accumulation.
  static final Map<String, Future<Uint8List?>> _thumbnailFutures = {};

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant MyVideoContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _thumbnailData = null;
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    if (widget.videoUrl.isEmpty) return;

    /// Already cached in memory
    final cached = VideoCacheManager.getCachedThumbnail(widget.videoUrl);

    if (cached != null) {
      if (mounted) {
        setState(() {
          _thumbnailData = cached;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final url = widget.videoUrl;
    try {
      /// Avoid multiple thumbnail generation for the same video.
      /// Entry is removed after resolution to free the Future reference.
      _thumbnailFutures[url] ??= _generateThumbnail(url).whenComplete(() {
        _thumbnailFutures.remove(url);
      });

      final data = await _thumbnailFutures[url];

      if (!mounted) return;

      if (data != null) {
        VideoCacheManager.cacheThumbnail(url, data);
        setState(() {
          _thumbnailData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Thumbnail Error => $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List?> _generateThumbnail(String videoUrl) async {
    try {
      final String fullUrl = videoUrl;

      final data = await VideoThumbnail.thumbnailData(
        video: fullUrl,
        imageFormat: ImageFormat.WEBP,
        maxHeight: 150,
        quality: 50,
        timeMs: 0,
      );

      return data;
    } catch (e) {
      debugPrint('Generate Thumbnail Failed => $e');
      return null;
    }
  }

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
              /// Background watermark
              Center(
                child: Opacity(
                  opacity: 0.10,
                  child: Image.asset(
                    AppIcons.videoClipP,
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                    cacheWidth: 120,
                    cacheHeight: 120,
                  ),
                ),
              ),

              /// Thumbnail
              if (_thumbnailData != null)
                Positioned.fill(
                  child: Image.memory(
                    _thumbnailData!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const SizedBox.shrink();
                    },
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

              /// Loading indicator
              if (_isLoading)
                const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white24,
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
