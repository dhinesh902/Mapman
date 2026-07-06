import 'dart:async';
import 'dart:io';

import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/home_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/home_model.dart';
import 'package:mapman/routes/api_routes.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/utils/storage/session_manager.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_launchers.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mapman/views/widgets/login_bottom_sheet.dart';
import 'package:mapman/views/widgets/skeleton_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late HomeController homeController;

  @override
  void initState() {
    // TODO: implement initState
    requestNotificationPermission();
    homeController = context.read<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.getNotificationCount();
      getHome();
      context.read<ProfileController>().getShopList();
    });
    super.initState();
  }

  Future<void> getHome() async {
    final response = await homeController.getHome();
    if (!mounted) return;
    if (response.status == Status.ERROR) {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }

    PermissionStatus status = await Permission.notification.status;

    // Already granted
    if (status.isGranted) {
      return true;
    }

    // Permanently denied
    if (status.isPermanentlyDenied) {
      return false;
    }

    // Request permission
    status = await Permission.notification.request();

    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Builder(
        builder: (context) {
          final isLoading =
              homeController.homeData.status == Status.INITIAL ||
              homeController.homeData.status == Status.LOADING;

          if (homeController.homeData.status == Status.ERROR) {
            return CustomErrorTextWidget(
              title: '${homeController.homeData.message}',
            );
          }

          final categories = isLoading
              ? List.generate(
                  8,
                  (index) =>
                      Category(id: index, categoryName: 'Category $index'),
                )
              : homeController.homeCategories;

          final topBanner = isLoading
              ? List.generate(
                  3,
                  (index) => TopBanners(
                    id: index,
                    title: 'Banner Title $index',
                    subtitle: 'Subtitle $index',
                  ),
                )
              : (homeController.homeData.data?.topBanners ?? []);

          final categoryBanners = isLoading
              ? List.generate(
                  3,
                  (index) => CategoryBanners(
                    id: index,
                    title: 'Category Banner $index',
                  ),
                )
              : (homeController.homeData.data?.categoryBanners ?? []);

          final homeData = isLoading
              ? HomeData(
                  userName: 'Profile Name',
                  profile: '',
                  topBanners: topBanner,
                  categoryBanners: categoryBanners,
                )
              : (homeController.homeData.data ?? HomeData());
          final homeShops = homeController.homeData.data?.shops ?? [];
          return Skeletonizer(
            enabled: isLoading,
            child: isLoading
                ? const HomeSkeleton()
                : Column(
                    children: [
                      HomeTopCard(
                        homeBanners: topBanner,
                        homeController: homeController,
                        homeData: homeData,
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 55,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [Colors.white, const Color(0xFFF4FFF5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: .18),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF4CAF50,
                              ).withValues(alpha: .10),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: AnimatedTextField(
                          animationType: Animationtype.typer,
                          readOnly: true,
                          onTap: () {
                            homeController.setFocusSearchOnMap = true;
                            homeController.setSearchCategory = 'all';
                            homeController.setIsShowAddNearBy = false;
                            homeController.setCurrentPage = 1;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: GenericColors.darkGreen.withValues(
                                  alpha: .12,
                                ),
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: GenericColors.darkGreen,
                                size: 18,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          hintTextStyle: AppTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText.withValues(alpha: .7),
                          ).textStyle,
                          hintTexts: const [
                            'Search for " restaurants "',
                            'Search for " mechanic shops "',
                            'Search for " grocery stores "',
                            'Search for " electricians "',
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                children: [
                                  HeaderTextBlack(
                                    title: 'Category',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(width: 50),
                                  Expanded(
                                    child: Divider(color: Color(0XFFE0E0E0)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 3,
                                    mainAxisExtent: 110,
                                  ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                bool isFurniture =
                                    categories[index].categoryName ==
                                    "furniture";
                                return GestureDetector(
                                  onTap: () {
                                    homeController.setCurrentPage = 1;
                                    homeController.setIsShowAddNearBy = true;
                                    homeController.setSearchCategory =
                                        categories[index].categoryName
                                            .toString()
                                            .toLowerCase();
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    AppColors.whiteText,
                                                    GenericColors.lightPrimary
                                                        .withValues(alpha: .6),
                                                  ],
                                                ),
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(6),
                                                    ),
                                              ),
                                              child: Center(
                                                child: isLoading
                                                    ? const SizedBox.shrink()
                                                    : Image.network(
                                                        '${ApiRoutes.baseUrl}${categories[index].categoryImage ?? ''}',
                                                        height: isFurniture
                                                            ? 55
                                                            : 40,
                                                        width: isFurniture
                                                            ? 55
                                                            : 40,
                                                        filterQuality:
                                                            FilterQuality.high,
                                                      ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.scaffoldBackground,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    bottom: Radius.circular(6),
                                                  ),
                                            ),
                                            child: Center(
                                              child: BodyTextColors(
                                                title:
                                                    categories[index]
                                                        .categoryName
                                                        ?.capitalize() ??
                                                    '',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0XFF1F1F1F),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 50),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: HeaderTextBlack(
                                title: 'Featured Locations',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10),
                            ListView.builder(
                              itemCount: homeShops.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ShopCard(shop: homeShops[index]);
                              },
                            ),
                            SizedBox(height: 100),
                            BottomCarousalSlider(
                              images: categoryBanners,
                              homeController: homeController,
                              height: 100,
                            ),
                            Container(
                              height: 153,
                              color: AppColors.scaffoldBackgroundDark,
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: EndMessageSection(title: 'MAP MAN'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class HomeTopCard extends StatelessWidget {
  const HomeTopCard({
    super.key,
    required this.homeBanners,
    required this.homeController,
    required this.homeData,
  });

  final List<TopBanners> homeBanners;
  final HomeController homeController;
  final HomeData homeData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.whiteText, GenericColors.homeTopPrimary],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: HomeTopListTile(
                homeController: homeController,
                name: homeData.userName ?? 'Profile Name',
                profileImage: homeData.profile ?? '',
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child: Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: homeBanners.length,
                  itemBuilder: (context, index, realIndex) {
                    final banner = homeBanners[index];

                    // return Container(
                    //   margin: const EdgeInsets.fromLTRB(4, 15, 4, 10),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(20),
                    //     color: AppColors.whiteText,
                    //     image: DecorationImage(
                    //       image: NetworkImage(
                    //         banner.backgroundImage?.startsWith('https') ?? false
                    //             ? banner.backgroundImage!
                    //             : '${ApiRoutes.baseUrl}${banner.backgroundImage ?? ''}',
                    //       ),
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                    //
                    //   padding: EdgeInsets.all(4),
                    //   clipBehavior: Clip.hardEdge,
                    //   child: Row(
                    //     children: [
                    //
                    //       Expanded(
                    //         flex: 5,
                    //         child: Padding(
                    //           padding: const EdgeInsets.symmetric(
                    //             horizontal: 16,
                    //             vertical: 5,
                    //           ),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               BodyTextColors(
                    //                 title: banner.title?.capitalize() ?? '',
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.w700,
                    //                 color: AppColors.whiteText,
                    //               ),
                    //
                    //               const SizedBox(height: 5),
                    //
                    //               BodyTextColors(
                    //                 title: banner.subtitle?.capitalize() ?? '',
                    //                 fontSize: 12,
                    //                 fontWeight: FontWeight.w300,
                    //                 color: AppColors.whiteText,
                    //               ),
                    //
                    //               const SizedBox(height: 20),
                    //               if (banner.title != null &&
                    //                   banner.title!.isNotEmpty) ...[
                    //                 InkWell(
                    //                   borderRadius: BorderRadius.circular(8),
                    //                   onTap: () async {
                    //                     final token = SessionManager.getToken();
                    //
                    //                     if (token == null) {
                    //                       await LoginBottomSheet.showLoginBottomSheet(
                    //                         context,
                    //                       );
                    //                       return;
                    //                     }
                    //
                    //                     await showAddShopDetail(context);
                    //                   },
                    //                   child: Container(
                    //                     height: 28,
                    //                     width: 120,
                    //                     decoration: BoxDecoration(
                    //                       color: index == 1
                    //                           ? AppColors.darkText
                    //                           : AppColors.primary,
                    //                       borderRadius: BorderRadius.circular(
                    //                         8,
                    //                       ),
                    //                     ),
                    //                     child: Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       children: [
                    //                         BodyTextColors(
                    //                           title: 'Register Now',
                    //                           fontSize: 12,
                    //                           fontWeight: FontWeight.w500,
                    //                           color: AppColors.whiteText,
                    //                         ),
                    //
                    //                         const SizedBox(width: 6),
                    //
                    //                         const Icon(
                    //                           Icons.arrow_forward_rounded,
                    //                           size: 16,
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
                    //
                    //
                    //       if (banner.image != null &&
                    //           banner.image!.isNotEmpty) ...[
                    //         SizedBox(
                    //           width: 130,
                    //           height: 170,
                    //           child: Image.network(
                    //             banner.image!.startsWith('https')
                    //                 ? '${banner.image}'
                    //                 : '${ApiRoutes.baseUrl}${banner.image ?? ""}',
                    //             fit: BoxFit.contain,
                    //           ),
                    //         ),
                    //       ],
                    //     ],
                    //   ),
                    // );
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.whiteText,
                      ),
                      padding: EdgeInsets.all(4),
                      clipBehavior: Clip.hardEdge,
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(20),
                        child: CustomNetworkImage(
                          imageUrl: banner.backgroundImage!.startsWith('https')
                              ? '${banner.backgroundImage}'
                              : '${ApiRoutes.baseUrl}${banner.backgroundImage ?? ""}',
                          boxFit: BoxFit.fill,
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 170,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                    enlargeCenterPage: false,
                    enableInfiniteScroll: true,
                    pageSnapping: true,
                    pauseAutoPlayOnTouch: true,
                    onPageChanged: (index, reason) {
                      homeController.setHomeBannerCurrentIndex(index);
                    },
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 0,
                  right: 0,
                  child: CustomIndicator(
                    currentIndex: homeController.homeBannerCurrentIndex,
                    itemCount: homeBanners.length,
                    activeWidth: 8,
                    inactiveWidth: 3,
                    borderHeight: 3,
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

class HomeTopListTile extends StatelessWidget {
  const HomeTopListTile({
    super.key,
    required this.homeController,
    required this.name,
    required this.profileImage,
  });

  final HomeController homeController;
  final String name, profileImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        leading: GestureDetector(
          onTap: () {
            homeController.setCurrentPage = 3;
          },
          child: SizedBox(
            height: 42,
            width: 42,
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(50),
              child: CustomNetworkImage(
                isProfile: true,
                imageUrl: profileImage,
              ),
            ),
          ),
        ),
        title: HeaderTextBlack(
          title: name.capitalize(),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: BodyTextHint(
          title: 'Have a nice day',
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleContainer(
              onTap: () {
                final token = SessionManager.getToken();
                if (token == null || token.isEmpty) {
                  LoginBottomSheet.showLoginBottomSheet(context);
                } else {
                  context.pushNamed(AppRoutes.savedVideos);
                }
              },
              child: Image.asset(AppIcons.bookmarkP, height: 30),
            ),
            SizedBox(width: 15),
            CircleContainer(
              onTap: () {
                final token = SessionManager.getToken();
                if (token == null || token.isEmpty) {
                  LoginBottomSheet.showLoginBottomSheet(context);
                } else {
                  context.pushNamed(AppRoutes.notifications);
                }
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: SvgPicture.asset(AppIcons.notification),
                  ),
                  Positioned(
                    right: homeController.notificationCountResponse.data == 0
                        ? 4
                        : 0,
                    top: homeController.notificationCountResponse.data == 0
                        ? 3
                        : 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Builder(
                        builder: (context) {
                          switch (homeController
                              .notificationCountResponse
                              .status) {
                            case Status.INITIAL:
                            case Status.LOADING:
                              return HeaderTextBlack(
                                title: '..',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              );
                            case Status.COMPLETED:
                              return BodyTextColors(
                                title:
                                    homeController
                                            .notificationCountResponse
                                            .data ==
                                        0
                                    ? ''
                                    : homeController
                                          .notificationCountResponse
                                          .data
                                          .toString(),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                textAlign: TextAlign.center,
                                color: AppColors.whiteText,
                              );
                            case Status.ERROR:
                              return BodyTextColors(
                                title: '',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.whiteText,
                              );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircleContainer extends StatelessWidget {
  const CircleContainer({
    super.key,
    required this.child,
    required this.onTap,
    this.color = AppColors.scaffoldBackground,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: child),
      ),
    );
  }
}

class BottomCarousalSlider extends StatelessWidget {
  const BottomCarousalSlider({
    super.key,
    required this.images,
    required this.homeController,
    required this.height,
  });

  final List<CategoryBanners> images;
  final HomeController homeController;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CarouselSlider(
            items: List.generate(images.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: NetworkImage(
                      images[index].backgroundImage?.startsWith('https') ??
                              false
                          ? images[index].backgroundImage!
                          : '${ApiRoutes.baseUrl}${images[index].backgroundImage ?? ''}',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BodyTextColors(
                            title: images[index].title?.capitalize() ?? "",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteText,
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              homeController.setCurrentPage = 1;
                              homeController.setIsShowAddNearBy = true;

                              homeController.setSearchCategory =
                                  images[index].category?.toLowerCase() ?? "";
                            },
                            child: Container(
                              height: 28,
                              width: 88,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: AppColors.darkText,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: BodyTextColors(
                                  title: 'Explore Now',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.whiteText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.network(
                        '${ApiRoutes.baseUrl}${images[index].image ?? ''}',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              );
            }),
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              autoPlay: false,
              autoPlayInterval: const Duration(seconds: 2),
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              onPageChanged: (index, reason) {
                homeController.setCarousalIndex(index);
              },
            ),
          ),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: CustomIndicator(
              currentIndex: homeController.carousalCurrentIndex,
              itemCount: images.length,
              activeWidth: 8,
              inactiveWidth: 3,
              borderHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomIndicator extends StatelessWidget {
  const CustomIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    required this.activeWidth,
    required this.inactiveWidth,
    required this.borderHeight,
  });

  final int currentIndex;
  final int itemCount;
  final double activeWidth, inactiveWidth, borderHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: borderHeight,
          width: currentIndex == index ? activeWidth : inactiveWidth,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: currentIndex == index
                ? AppColors.whiteText
                : GenericColors.borderGrey,
          ),
        ),
      ),
    );
  }
}

class ShopCard extends StatelessWidget {
  final HomeShops shop;

  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final image =
        shop.shopImage ??
        shop.image1 ??
        "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80";

    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRoutes.shopDetail, extra: shop.id ?? 0);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.whiteText,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: GenericColors.borderGrey.withValues(alpha: .5),
          ),
          boxShadow: [
            BoxShadow(
              color: GenericColors.darkGreen.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: image.isNotEmpty
                    ? CustomNetworkImage(
                        imageUrl: image.startsWith('http')
                            ? image
                            : '${ApiRoutes.baseUrl}$image',
                        boxFit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.scaffoldBackgroundDark,
                        child: const Center(
                          child: Icon(
                            Icons.storefront,
                            size: 50,
                            color: GenericColors.borderGrey,
                          ),
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: GenericColors.lightPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: BodyTextColors(
                      title: shop.category?.capitalize() ?? 'Shop',
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  HeaderTextBlack(
                    title: shop.shopName ?? 'Unknown Shop',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  if (shop.description != null &&
                      shop.description!.isNotEmpty) ...[
                    BodyTextColors(
                      title: shop.description!,
                      color: AppColors.darkText.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: BodyTextColors(
                          title: shop.address ?? 'Address not available',
                          color: AppColors.darkText.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(
                    color: GenericColors.borderGrey.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: GenericColors.darkGreen,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: BodyTextColors(
                          title:
                              "${shop.openTime ?? '-'} to ${shop.closeTime ?? '-'}",
                          color: AppColors.darkText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await CustomLaunchers.openGoogleMaps(
                              latitude: double.parse(shop.lat ?? ''),
                              longitude: double.parse(shop.long ?? ''),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                BodyTextColors(
                                  title: 'Direction',
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            await CustomLaunchers.makePhoneCall(
                              phoneNumber: shop.registerNumber ?? '',
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.call_rounded,
                                  size: 16,
                                  color: AppColors.whiteText,
                                ),
                                const SizedBox(width: 6),
                                BodyTextColors(
                                  title: 'Call',
                                  color: AppColors.whiteText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
