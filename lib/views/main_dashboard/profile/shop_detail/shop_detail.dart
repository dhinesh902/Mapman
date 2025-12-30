import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/single_shop_detaildata.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/main_dashboard/video/single_video_screen.dart';
import 'package:mapman/views/main_dashboard/video/videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_launchers.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class ShopDetail extends StatefulWidget {
  const ShopDetail({super.key, required this.shopId});

  final int shopId;

  @override
  State<ShopDetail> createState() => _ShopDetailState();
}

class _ShopDetailState extends State<ShopDetail> {
  late VideoController videoController;

  @override
  void initState() {
    // TODO: implement initState
    videoController = context.read<VideoController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getShopById();
    });
    super.initState();
  }

  Future<void> getShopById() async {
    final response = await videoController.getShopById(shopId: widget.shopId);
    if (!mounted) return;
    if (response.status == Status.ERROR) {
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
    final lat = videoController.singleShopDetailData.data?.shop?.lat ?? '0.0';
    final long = videoController.singleShopDetailData.data?.shop?.long ?? '0.0';
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(
          title:
              videoController.singleShopDetailData.data?.shop?.shopName
                  ?.capitalize() ??
              '......',
          action: ShopLocationButton(
            onTap: () async {
              await CustomLaunchers.openGoogleMaps(
                latitude: double.parse(lat),
                longitude: double.parse(long),
              );
            },
          ),
          isCenterTitle: false,
        ),
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
                      title: 'Shop Details',
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

            Builder(
              builder: (context) {
                switch (videoController.singleShopDetailData.status) {
                  case Status.INITIAL:
                  case Status.LOADING:
                    return Expanded(child: const CustomLoadingIndicator());
                  case Status.COMPLETED:
                    if (videoController.singleShopDetailData.data != null) {
                      return videoController.currentShopDetailIndex == 0
                          ? ShopDetailContainer(
                              shop:
                                  videoController
                                      .singleShopDetailData
                                      .data
                                      ?.shop ??
                                  Shop(),
                            )
                          : Expanded(
                              child: ShopVideosList(
                                shopVideos:
                                    videoController
                                        .singleShopDetailData
                                        .data
                                        ?.shopVideos ??
                                    [],
                              ),
                            );
                    } else {
                      return Expanded(
                        child: NoDataText(title: Strings.noDataFound),
                      );
                    }

                  case Status.ERROR:
                    return Expanded(
                      child: CustomErrorTextWidget(
                        title:
                            '${videoController.singleShopDetailData.message}',
                      ),
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ShopDetailContainer extends StatelessWidget {
  const ShopDetailContainer({super.key, required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      shop.image1,
      shop.image2,
      shop.image3,
      shop.image4,
    ].where((e) => e != null && e.trim().isNotEmpty).cast<String>().toList();

    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          child: CustomNetworkImage(imageUrl: shop.shopImage ?? ''),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .6,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
            children: [
              SizedBox(height: 15),
              CustomTextFieldContainer(
                title: 'Shop Name',
                child: HeaderTextBlack(
                  title: shop.shopName ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 15),
              CustomTextFieldContainer(
                title: 'Address',
                child: HeaderTextBlack(
                  title: shop.address ?? '',
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
                      onTap: () async {
                        await CustomLaunchers.sendSms(
                          phoneNumber: '${shop.shopNumber}',
                        );
                      },
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
                      onTap: () async {
                        await CustomLaunchers.makePhoneCall(
                          phoneNumber: '${shop.registerNumber}',
                        );
                      },
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
                      onTap: () async {
                        await CustomLaunchers.openGoogleMaps(
                          latitude: double.parse(shop.lat ?? '0.0'),
                          longitude: double.parse(shop.long ?? '0.0'),
                        );
                      },
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
              SizedBox(height: 35),
              if (images.isNotEmpty) ImageSliderWithArrows(images: images),
              SizedBox(height: 15),
              CustomTextFieldContainer(
                title: 'Opening- Closing Time',
                child: HeaderTextBlack(
                  title: '${shop.openTime} - ${shop.closeTime}',
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
  const ShopVideosList({super.key, required this.shopVideos});

  final List<VideosData> shopVideos;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 15),
        for (int index = 0; index < shopVideos.length; index++) ...[
          Container(
            height: 174,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
            margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    // context.pushNamed(
                    //   AppRoutes.singleVideoScreen,
                    //   extra: {
                    //     Keys.videosData: shopVideos[index],
                    //     Keys.isMyVideos: false,
                    //   },
                    // );
                  },
                  child: MyVideoContainer(
                    videoUrl:
                        ApiRoutes.baseUrl + (shopVideos[index].video ?? ''),
                    views: '${shopVideos[index].views ?? 0}',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoTitleBlurContainer(videosData: shopVideos[index]),
                ),
              ],
            ),
          ),
        ],
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

class ImageSliderWithArrows extends StatefulWidget {
  const ImageSliderWithArrows({super.key, required this.images});

  final List<String> images;

  @override
  State<ImageSliderWithArrows> createState() => _ImageSliderWithArrowsState();
}

class _ImageSliderWithArrowsState extends State<ImageSliderWithArrows> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  bool get _isFirstPage => _currentIndex == 0;

  bool get _isLastPage => _currentIndex == widget.images.length - 1;

  void _nextPage() {
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (!_isFirstPage) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 175,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors.scaffoldBackground,
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (_, index) {
              return CustomNetworkImage(imageUrl: widget.images[index]);
            },
          ),
        ),

        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                const SizedBox(width: 30),
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: BodyTextHint(
                    title: 'Image uploaded (${widget.images.length})',
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Spacer(),
                ImagesBackAndForwardContainer(
                  onTap: _previousPage,
                  icon: Icons.keyboard_arrow_left_sharp,
                  isActive: !_isFirstPage,
                ),
                const SizedBox(width: 4),
                ImagesBackAndForwardContainer(
                  onTap: _nextPage,
                  icon: Icons.keyboard_arrow_right_sharp,
                  isActive: !_isLastPage,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ImagesBackAndForwardContainer extends StatelessWidget {
  const ImagesBackAndForwardContainer({
    super.key,
    required this.onTap,
    required this.icon,
    required this.isActive,
  });

  final bool isActive;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GenericColors.placeHolderGrey,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? AppColors.primary : AppColors.darkGrey,
        ),
      ),
    );
  }
}
