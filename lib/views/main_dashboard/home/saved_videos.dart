import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/notification/viewed_videos.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class SavedVideos extends StatefulWidget {
  const SavedVideos({super.key});

  @override
  State<SavedVideos> createState() => _SavedVideosState();
}

class _SavedVideosState extends State<SavedVideos> {
  late VideoController videoController;

  @override
  void initState() {
    // TODO: implement initState
    videoController = context.read<VideoController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMySavedVideos();
    });
    super.initState();
  }

  Future<void> getMySavedVideos() async {
    final response = await videoController.getMySavedVideos();
    if (!mounted) return;
    if (response.status == Status.ERROR) {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  Future<void> addSavedVideos({
    required int videoId,
    required String status,
  }) async {
    CustomDialogues.showLoadingDialogue(context);
    final response = await videoController.addSavedVideos(
      videoId: videoId,
      status: status,
    );
    if (!mounted) return;
    if (response.status == Status.COMPLETED) {
      CustomToast.show(context, title: 'Video unsaved successfully ');
      await context.read<VideoController>().getMySavedVideos(
        removeBookMark: false,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
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
    final videoData = videoController.savedVideoData.data ?? [];
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                AppIcons.notificationTopCardP,
                fit: BoxFit.cover,
                cacheWidth: 600,
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ActionBarComponent(title: 'Saved Videos'),
                  TopPromoBanner(),
                  if (videoData.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                      child: HeaderTextBlack(
                        title: 'Total Saved Videos (${videoData.length})',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  Flexible(
                    child: Builder(
                      builder: (context) {
                        switch (videoController.savedVideoData.status) {
                          case Status.INITIAL:
                            return CustomLoadingIndicator();
                          case Status.LOADING:
                            return CustomLoadingIndicator();
                          case Status.COMPLETED:
                            final savedVideos =
                                videoController.savedVideoData.data ?? [];

                            ///Start Watching Videos & Earn Rewards
                            if (savedVideos.isEmpty) {
                              return EmptyDataContainer(

                                children: [
                                  Image.asset(
                                    AppIcons.savedVideoEmptyP,
                                    height: 140,
                                    width: 140,
                                  ),
                                  SizedBox(height: 20),
                                  BodyTextHint(
                                    title: 'No Data Found here',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              itemCount: savedVideos.length,
                              itemBuilder: (context, index) {
                                return SavedVideoCard(
                                  videosData: savedVideos[index],
                                  isBookMark: true,
                                  allVideos: savedVideos,
                                  currentIndex: index,
                                  bookMarkOnTap: () async {
                                    await addSavedVideos(
                                      videoId: savedVideos[index].id ?? 0,
                                      status: 'inactive',
                                    );
                                  },
                                );
                              },
                            );
                          case Status.ERROR:
                            return CustomErrorTextWidget(
                              title:
                                  '${videoController.savedVideoData.message}',
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

class TopPromoBanner extends StatelessWidget {
  const TopPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned.fill(
            child: Container(
              height: 81,
              margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  image: AssetImage(AppIcons.savedVideoBg),
                  fit: BoxFit.cover,
                ),
                color: AppColors.scaffoldBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 20,
            bottom: 0,
            child: Image.asset(
              AppIcons.savedVideoMan,
              height: 120,
              cacheWidth: 200,
            ),
          ),

          Positioned(
            right: 60,
            top: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderTextPrimary(
                  title: 'Enroll shop owners',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 15),
                Container(
                  height: 24,
                  width: 91,
                  decoration: BoxDecoration(
                    color: AppColors.darkText,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: BodyTextColors(
                      title: 'Register Now',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SavedVideoCard extends StatelessWidget {
  const SavedVideoCard({
    super.key,
    required this.videosData,
    required this.isBookMark,
    required this.bookMarkOnTap,
    this.allVideos,
    this.currentIndex,
  });

  final VideosData videosData;
  final bool isBookMark;
  final VoidCallback bookMarkOnTap;
  final List<VideosData>? allVideos;
  final int? currentIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: RepaintBoundary(
        child: Stack(
          children: [
            ViewedVideoCard(
              videoUrl: ApiRoutes.baseUrl + (videosData.video ?? ''),
              isBookMark: isBookMark,
              bookMarkOnTap: bookMarkOnTap,
              onTap: () {
                final videosList = allVideos ?? [videosData];
                final index = currentIndex ?? 0;
                context.pushNamed(
                  AppRoutes.singleVideoScreen,
                  extra: {
                    Keys.videosData: videosList,
                    Keys.isMyVideos: false,
                    Keys.initialIndex: index,
                  },
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoTitleBlurContainer(
                isShopDetail: true,
                videosData: videosData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
