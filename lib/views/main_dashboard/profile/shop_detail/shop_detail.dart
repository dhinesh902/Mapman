import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/controller/video_controller.dart';
import 'package:mapman/model/single_shop_detaildata.dart';
import 'package:mapman/model/video_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/main_dashboard/video/components/video_shop_dialogue.dart';
import 'package:mapman/views/main_dashboard/video/my_videos.dart';
import 'package:mapman/views/main_dashboard/video/single_video_screen.dart';
import 'package:mapman/views/main_dashboard/video/videos.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
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
      videoController.setCurrentShopDetailIndex = 0;
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

  String shopName(Status status, String? shopName) {
    if (status == Status.LOADING) {
      return '......';
    } else if (status == Status.COMPLETED) {
      return shopName?.capitalize() ?? '';
    } else {
      return '';
    }
  }

  Future<void> savedShops({required int shopId, required String status}) async {
    CustomDialogues.showLoadingDialogue(context);
    final response = await context.read<ProfileController>().saveShop(
      shopId: shopId,
      status: status,
    );
    if (!mounted) return;
    Navigator.pop(context);
    if (response.status == Status.COMPLETED) {
      videoController.setIsSaveShop(status == 'active' ? true : false);
      context.read<ProfileController>().getFetchSavedShops(page: 1);
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
    final isLoading =
        videoController.singleShopDetailData.status == Status.INITIAL ||
        videoController.singleShopDetailData.status == Status.LOADING;

    final mockShop = Shop(
      id: 1,
      shopName: 'Mock Shop Name',
      category: 'theater',
      address: '123 Mock Address Road',
      openTime: '09:00 AM',
      closeTime: '09:00 PM',
      shopNumber: '1234567890',
      lat: '0.0',
      long: '0.0',
      image1: '',
      image2: '',
      image3: '',
      image4: '',
      shopImage: '',
    );

    final mockVideos = List.generate(
      3,
      (index) => VideosData(
        id: index,
        videoTitle: 'Mock Video Title $index',
        thumbnail: '',
        views: 123,
      ),
    );

    final shopDetailData = isLoading
        ? SingleShopDetailData(shop: mockShop, shopVideos: mockVideos)
        : videoController.singleShopDetailData.data;

    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(
          title: isLoading
              ? 'Mock Shop Name'
              : (videoController.singleShopDetailData.data?.shop?.shopName
                        ?.capitalize() ??
                    ''),
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShopShopButton(
                onTap: () {
                  VideoShopDialogue().showReportShopDialogue(
                    context,
                    shopName:
                        videoController
                            .singleShopDetailData
                            .data
                            ?.shop
                            ?.shopName ??
                        '',
                    shopLocation:
                        videoController
                            .singleShopDetailData
                            .data
                            ?.shop
                            ?.address ??
                        '',
                  );
                },
                child: Center(
                  child: Image.asset(AppIcons.alertP, height: 24, width: 24),
                ),
              ),
              shopDetailData != null
                  ? ShopShopButton(
                      onTap: () {
                        VideoShopDialogue().showSaveOrRemoveShopDialogue(
                          context,
                          isRemoveShop: videoController.isSaveShop,
                          onTap: () async {
                            await savedShops(
                              shopId: shopDetailData.shop?.id ?? 0,
                              status: videoController.isSaveShop
                                  ? 'inactive'
                                  : 'active',
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (videoController.isSaveShop)
                            Image.asset(
                              AppIcons.bookmarkP,
                              height: 24,
                              width: 24,
                            )
                          else
                            Icon(
                              Icons.bookmark_border_outlined,
                              size: 20,
                              color: AppColors.darkGrey,
                            ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
          isCenterTitle: false,
        ),
        body: Builder(
          builder: (context) {
            if (videoController.singleShopDetailData.status == Status.ERROR) {
              return CustomErrorTextWidget(
                title: '${videoController.singleShopDetailData.message}',
              );
            }

            final shopVideos = shopDetailData?.shopVideos ?? [];
            if (isLoading) {
              return CustomLoadingIndicator();
            }
            return Column(
              children: [
                SizedBox(height: 15),
                if (shopDetailData != null) ...[
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
                            isActive:
                                videoController.currentShopDetailIndex == 0,
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
                            isActive:
                                videoController.currentShopDetailIndex == 1,
                            isLeft: false,
                            onTap: () {
                              videoController.setCurrentShopDetailIndex = 1;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (shopDetailData != null) ...[
                  if (videoController.currentShopDetailIndex == 0)
                    ShopDetailContainer(shop: shopDetailData.shop ?? Shop())
                  else ...[
                    if (shopVideos.isEmpty && !isLoading)
                      EmptyDataContainer(
                        children: [
                          Image.asset(
                            AppIcons.playVideoP,
                            height: 130,
                            width: 130,
                          ),
                          SizedBox(height: 20),
                          BodyTextColors(
                            title: 'No shop videos found',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.lightGreyHint,
                          ),
                        ],
                      )
                    else
                      Expanded(child: ShopVideosList(shopVideos: shopVideos)),
                  ],
                ] else ...[
                  EmptyDataContainer(
                    children: [
                      Image.asset(AppIcons.shopP, height: 120, width: 120),
                      SizedBox(height: 20),
                      BodyTextColors(
                        title: 'This shop is currently unavailable!!',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGreyHint,
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class ShopDetailContainer extends StatelessWidget {
  ShopDetailContainer({super.key, required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      shop.image1,
      shop.image2,
      shop.image3,
      shop.image4,
    ].where((e) => e != null && e.trim().isNotEmpty).cast<String>().toList();

    bool isShopClosed() {
      try {
        if ((shop.openTime ?? '').trim().isEmpty ||
            (shop.closeTime ?? '').trim().isEmpty) {
          return false;
        }

        int convertToMinutes(String value) {
          value = value.trim().toUpperCase();

          bool isPM = value.contains('PM');
          bool isAM = value.contains('AM');

          value = value.replaceAll('AM', '').replaceAll('PM', '').trim();

          final parts = value.split(':');

          int hour = int.parse(parts[0]);

          int minute = 0;
          if (parts.length > 1) {
            minute = int.parse(parts[1]);
          }

          if (isPM && hour < 12) {
            hour += 12;
          }

          if (isAM && hour == 12) {
            hour = 0;
          }

          return hour * 60 + minute;
        }

        final now = TimeOfDay.now();
        final nowMinutes = now.hour * 60 + now.minute;

        final openMinutes = convertToMinutes(shop.openTime!);
        final closeMinutes = convertToMinutes(shop.closeTime!);

        bool isOpen;

        if (openMinutes < closeMinutes) {
          // same day
          isOpen = nowMinutes >= openMinutes && nowMinutes < closeMinutes;
        } else {
          // overnight
          isOpen = nowMinutes >= openMinutes || nowMinutes < closeMinutes;
        }

        return !isOpen;
      } catch (e) {
        debugPrint('TIME ERROR => $e');
        debugPrint('OPEN => ${shop.openTime}');
        debugPrint('CLOSE => ${shop.closeTime}');
        return false;
      }
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.black,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Stack(
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 130,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.whiteText,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: InteractiveViewer(
                                      minScale: 0.8,
                                      maxScale: 4,
                                      child: Hero(
                                        tag: shop.shopImage ?? '',
                                        child: CustomNetworkImage(
                                          imageUrl:
                                              shop.shopImage ??
                                              getUnKnownShopImages(
                                                shop.shopImage ?? '',
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 50,
                              right: 20,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.circular(10),
              color: AppColors.whiteText,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 1,
                  blurRadius: 1,
                ),
              ],
            ),
            padding: EdgeInsets.all(4),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomNetworkImage(
                    imageUrl:
                        shop.shopImage ??
                        getUnKnownShopImages(shop.shopImage ?? ''),
                  ),
                ),
                if (isShopClosed()) ...[
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: GenericColors.darkRed,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppIcons.videoShop,
                            height: 16,
                            width: 16,
                            colorFilter: ColorFilter.mode(
                              AppColors.whiteText,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 6),
                          BodyTextColors(
                            title: 'Shop Closed',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: GenericColors.darkGreen,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppIcons.videoShop,
                            height: 16,
                            width: 16,
                            colorFilter: ColorFilter.mode(
                              AppColors.whiteText,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 6),
                          BodyTextColors(
                            title: 'Shop Open',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                title: 'Category',
                child: HeaderTextBlack(
                  title: shop.category?.capitalize() ?? '',
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
              if (shop.websiteLink != null && shop.websiteLink!.isNotEmpty) ...[
                SizedBox(height: 15),
                CustomTextFieldContainer(
                  title: 'Website',
                  onTap: () async {
                    await CustomLaunchers.openWebsite(url: shop.websiteLink!);
                  },
                  child: HeaderTextPrimary(
                    title: shop.websiteLink ?? '',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                          AppIcons.whatsappP,
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
                          phoneNumber: '${shop.shopNumber}',
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
                        final double? lat = double.tryParse(shop.lat ?? '');
                        final double? long = double.tryParse(shop.long ?? '');
                        if (lat == null || long == null) {
                          CustomToast.show(
                            context,
                            title: 'Invalid coordinates for directions',
                            isError: true,
                          );
                          return;
                        }
                        await CustomLaunchers.openGoogleMaps(
                          latitude: lat,
                          longitude: long,
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
              SizedBox(height: 60),
            ],
          ),
        ),
      ],
    );
  }

  final Map<String, String> iconImageMap = {
    "theater":
        "https://img.freepik.com/free-photo/3d-rendering-cinema-teather_23-2151169422.jpg?semt=ais_hybrid&w=740&q=80",
    "restaurant":
        "https://img.freepik.com/free-vector/cafe-restaurant-interior_107791-30184.jpg",
    "hospital":
        "https://static.vecteezy.com/system/resources/previews/005/317/601/non_2x/elderly-patient-in-front-the-hospital-vector.jpg",
    "bar":
        "https://img.freepik.com/free-vector/bar-table-pub-interior-cartoon-background_107791-28898.jpg?semt=ais_incoming&w=740&q=80",
    "grocery":
        "https://img.freepik.com/premium-photo/supermarket-business-vertical-poster-template_1257223-126129.jpg",
    "textile":
        "https://thumbs.dreamstime.com/b/fashion-store-interior-counter-mannequins-fashion-store-interior-counter-mannequins-hangers-showcase-191363271.jpg",
    "resort":
        "https://img.freepik.com/free-vector/outdoor-swimming-pool-colored-background-with-chaise-lounges-umbrella-palm-trees-cartoon-vector-illustration_1284-79719.jpg?semt=ais_hybrid&w=740&q=80",
    "bunk":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRnf86j1Yv60Wd43cezQvFKwKABzdSvMctmig&s",
    "spa":
        "https://img.freepik.com/premium-vector/cosmetology-salon-flat-color-illustration-spa-massage-hair-removal-sugaring-services-skincare-procedures-equipment-2d-cartoon-interior-with-furniture-background_151150-2759.jpg",
    "hotel":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4DhNVE0f2RF1DAYAbz5GWoluf-fuMQ5SQUw&s",
  };

  String getUnKnownShopImages(String category) {
    return iconImageMap[category] ??
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_x6m1vACqgzs9-dxIZq-d6JYFbkJHkvdpCw&s";
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
                    context.pushNamed(
                      AppRoutes.singleVideoScreen,
                      extra: {
                        Keys.videosData: shopVideos,
                        Keys.isMyVideos: false,
                        Keys.initialIndex: index,
                      },
                    );
                  },
                  child: MyVideoContainer(
                    thumbnail: shopVideos[index].thumbnail ?? '',
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
        if (shopVideos.length > 3) ...[
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

  /// 🔥 Updated Dialog with Slider
  void _showImageDialog(int initialIndex) {
    final PageController dialogController = PageController(
      initialPage: initialIndex,
    );

    int currentIndex = initialIndex;

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isFirst = currentIndex == 0;
            bool isLast = currentIndex == widget.images.length - 1;

            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 130,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: PageView.builder(
                              controller: dialogController,
                              itemCount: widget.images.length,
                              onPageChanged: (index) {
                                setState(() => currentIndex = index);
                              },
                              itemBuilder: (_, index) {
                                return InteractiveViewer(
                                  minScale: 0.8,
                                  maxScale: 4,
                                  child: Hero(
                                    tag: widget.images[index],
                                    child: CustomNetworkImage(
                                      imageUrl: widget.images[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (!isFirst)
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              dialogController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: _arrowButton(Icons.keyboard_arrow_left),
                          ),
                        ),
                      ),

                    if (!isLast)
                      Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              dialogController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: _arrowButton(Icons.keyboard_arrow_right),
                          ),
                        ),
                      ),

                    Positioned(
                      top: 50,
                      right: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _arrowButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
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
              return GestureDetector(
                onTap: () {
                  _showImageDialog(index);
                },
                child: CustomNetworkImage(imageUrl: widget.images[index]),
              );
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
