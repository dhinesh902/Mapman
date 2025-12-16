import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/notification/viewed_videos.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';

class SavedVideos extends StatefulWidget {
  const SavedVideos({super.key});

  @override
  State<SavedVideos> createState() => _SavedVideosState();
}

class _SavedVideosState extends State<SavedVideos> {
  final List<String> videoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
  ];

  @override
  Widget build(BuildContext context) {
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
                  const Padding(
                    padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                    child: HeaderTextBlack(
                      title: 'Total Saved Videos (6)',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      itemCount: videoUrls.length,
                      itemBuilder: (context, index) {
                        return SavedVideoCard(url: videoUrls[index]);
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
  const SavedVideoCard({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: RepaintBoundary(
        child: Stack(
          children: [
            ViewedVideoCard(
              videoUrl: url,
              isBookMark: true,
              bookMarkOnTap: () {},
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoTitleBlurContainer(
                isShopDetail: true,
                title: 'Video Title',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
