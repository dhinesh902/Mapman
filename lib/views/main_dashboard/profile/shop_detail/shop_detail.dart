import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/main_dashboard/video/videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:provider/provider.dart';

class ShopDetail extends StatefulWidget {
  const ShopDetail({super.key});

  @override
  State<ShopDetail> createState() => _ShopDetailState();
}

class _ShopDetailState extends State<ShopDetail> {
  late VideoController videoController;

  @override
  void initState() {
    // TODO: implement initState
    videoController = context.read<VideoController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    videoController = context.watch<VideoController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: 'Teddy Shop', action: Container()),
        body: Column(
          children: [
            SizedBox(height: 15),
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.bgGrey, // background for outer
              ),
              child: Row(
                children: [
                  Expanded(
                    child: VideoHeadingContainer(
                      title: 'Shop',
                      icon: AppIcons.shopP,
                      isActive: videoController.currentShopDetailIndex == 0,
                      isLeft: true,
                      onTap: () {
                        videoController.setCurrentShopDetailIndex = 0;
                      },
                    ),
                  ),
                  Expanded(
                    child: VideoHeadingContainer(
                      title: 'Videos',
                      icon: AppIcons.videoAppP,
                      isActive: videoController.currentShopDetailIndex == 1,
                      isLeft: false,
                      onTap: () {
                        videoController.setShowParticularShopVideos = false;
                        videoController.setCurrentShopDetailIndex = 1;
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// Shop Details
            if (videoController.currentShopDetailIndex == 0) ...[
              Expanded(child: ShopDetailContainer()),
            ],

            /// Videos
            if (videoController.currentShopDetailIndex == 1) ...[
              SizedBox(height: 15),
              Flexible(
                child: ShopVideosList(
                  videoUrls: [
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ShopDetailContainer extends StatelessWidget {
  const ShopDetailContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          child: CustomNetworkImage(
            imageUrl:
                'https://m.media-amazon.com/images/X/bxt1/M/Lbxt1B41JxtQJru._SL640_QL75_FMwebp_.jpg',
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
            children: [
              SizedBox(height: 15),
              CustomTextFieldContainer(
                title: 'Shop Name',
                child: HeaderTextBlack(
                  title: 'South Indian Restaurant',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 15),
              CustomTextFieldContainer(
                title: 'Address',
                child: HeaderTextBlack(
                  title:
                      'new no 17 old no 5 5 somu chetty 1st street,  Chinnathambi St, Royapuram, Chennai, Tamil Nadu 600013',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFieldContainer(
                      title: 'Chat with me',
                      child: Center(
                        child: Image.asset(
                          AppIcons.commentsP,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: CustomTextFieldContainer(
                      title: 'Direct Call',
                      child: Center(
                        child: Image.asset(
                          AppIcons.callGreenP,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: CustomTextFieldContainer(
                      title: 'Get Direction',
                      child: Center(
                        child: Image.asset(
                          AppIcons.locationPinP,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              CustomTextFieldContainer(
                title: 'Opening- Closing Time',
                child: HeaderTextBlack(
                  title: '10 Am - 10 Pm',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: EndMessageSection(title: 'Thanks for \nScrolling!!'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShopVideosList extends StatelessWidget {
  const ShopVideosList({super.key, required this.videoUrls});

  final List<String> videoUrls;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListView.builder(
          itemCount: videoUrls.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 10),
          itemBuilder: (context, index) {
            return Container(
              height: 174,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {},
                    child: MyVideoContainer(videoUrl: videoUrls[index]),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoTitleBlurContainer(),
                  ),
                ],
              ),
            );
          },
        ),
        Container(
          height: 150,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(AppIcons.locationLastPinP),
              Transform.rotate(
                angle: 1.5708,
                child: OutlineText(title: 'Map Man', fontSize: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
