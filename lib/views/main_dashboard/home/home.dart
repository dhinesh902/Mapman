import 'dart:async';
import 'dart:io';
import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppIcons.homeBgP),
            opacity: .4,
            fit: BoxFit.cover,
          ),
        ),
        child: Builder(
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
            final shopBanners = homeController.homeData.data?.shopBanners ?? [];
            return Skeletonizer(
              enabled: isLoading,
              child: isLoading
                  ? const HomeSkeleton()
                  : Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppIcons.arcBgP),
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                      child: CustomScrollView(
                        slivers: [
                          SliverLayoutBuilder(
                            builder:
                                (
                                  BuildContext context,
                                  SliverConstraints constraints,
                                ) {
                                  final isCollapsed =
                                      constraints.scrollOffset > 200;

                                  return SliverAppBar(
                                    expandedHeight: 320,
                                    automaticallyImplyLeading: false,
                                    pinned: true,
                                    floating: false,
                                    backgroundColor: isCollapsed
                                        ? Colors.blue.shade50
                                        : Colors.transparent,
                                    surfaceTintColor: isCollapsed
                                        ? Colors.pink.shade50
                                        : Colors.transparent,
                                    elevation: 0,
                                    titleSpacing: 0,
                                    title: HomeTopListTile(
                                      homeController: homeController,
                                      name: homeData.userName ?? 'Profile Name',
                                      profileImage: homeData.profile ?? '',
                                    ),
                                    flexibleSpace: FlexibleSpaceBar(
                                      collapseMode: CollapseMode.pin,
                                      background: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 75,
                                            ),
                                            child: CarouselSlider.builder(
                                              itemCount: topBanner.length,
                                              itemBuilder: (context, index, realIndex) {
                                                final banner = topBanner[index];
                                                final imageUrl =
                                                    banner.backgroundImage
                                                            ?.startsWith(
                                                              'https',
                                                            ) ==
                                                        true
                                                    ? banner.backgroundImage!
                                                    : '${ApiRoutes.baseUrl}${banner.backgroundImage ?? ''}';

                                                return Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8,
                                                      ),
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.whiteText,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 1,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  clipBehavior: Clip.hardEdge,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    child: CustomNetworkImage(
                                                      imageUrl: imageUrl,
                                                      boxFit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                              options: CarouselOptions(
                                                height: 180,
                                                viewportFraction: 1.0,
                                                autoPlay: true,
                                                autoPlayInterval:
                                                    const Duration(seconds: 5),
                                                autoPlayAnimationDuration:
                                                    const Duration(
                                                      milliseconds: 800,
                                                    ),
                                                enlargeCenterPage: false,
                                                enableInfiniteScroll: true,
                                                pageSnapping: true,
                                                pauseAutoPlayOnTouch: true,
                                                onPageChanged: (index, reason) {
                                                  homeController
                                                      .setHomeBannerCurrentIndex(
                                                        index,
                                                      );
                                                },
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 12,
                                            child: CustomIndicator(
                                              currentIndex: homeController
                                                  .homeBannerCurrentIndex,
                                              itemCount: topBanner.length,
                                              activeWidth: 8,
                                              inactiveWidth: 3,
                                              borderHeight: 3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    bottom: PreferredSize(
                                      preferredSize: Size(double.maxFinite, 70),
                                      child: Container(
                                        height: 50,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        padding: const EdgeInsets.all(1.2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.primaryBorder
                                                  .withValues(alpha: .55),
                                              AppColors.primary.withValues(
                                                alpha: .25,
                                              ),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: .12),
                                              blurRadius: 14,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.whiteText,
                                            borderRadius: BorderRadius.circular(
                                              29,
                                            ),
                                          ),
                                          child: AnimatedTextField(
                                            animationType: Animationtype.typer,
                                            readOnly: true,
                                            onTap: () {
                                              homeController
                                                      .setFocusSearchOnMap =
                                                  true;
                                              homeController.setSearchCategory =
                                                  'all';
                                              homeController
                                                      .setIsShowAddNearBy =
                                                  false;
                                              homeController.setCurrentPage = 1;
                                            },
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: AppColors.whiteText,

                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 15,
                                                  ),

                                              prefixIcon: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                  right: 4,
                                                  top: 7,
                                                  bottom: 7,
                                                ),
                                                child: Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        GenericColors
                                                            .lightPrimary
                                                            .withValues(
                                                              alpha: .18,
                                                            ),
                                                        GenericColors
                                                            .lightPrimary
                                                            .withValues(
                                                              alpha: .08,
                                                            ),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.search_rounded,
                                                    color: AppColors.primary,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(29),
                                                borderSide: BorderSide.none,
                                              ),

                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(29),
                                                borderSide: BorderSide.none,
                                              ),

                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(29),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),

                                            hintTextStyle: AppTextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.darkText
                                                  .withValues(alpha: .62),
                                            ).textStyle,

                                            hintTexts: const [
                                              'Search restaurants',
                                              'Search mechanic shops',
                                              'Search grocery stores',
                                              'Search electricians',
                                              'Search hotels',
                                              'Search medical shops',
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          ),
                          SliverToBoxAdapter(child: const SizedBox(height: 10)),
                          SliverToBoxAdapter(
                            child: Padding(
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
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: 10)),
                          SliverToBoxAdapter(
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 10,
                                    mainAxisExtent: 93,
                                  ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];

                                final categoryName =
                                    category.categoryName?.toLowerCase() ?? '';

                                final isFurniture = categoryName == 'furniture';

                                final categoryColor = Colors
                                    .primaries[index % Colors.primaries.length];

                                return GestureDetector(
                                  onTap: () {
                                    homeController.setCurrentPage = 1;
                                    homeController.setIsShowAddNearBy = true;
                                    homeController.setSearchCategory =
                                        categoryName;
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteText,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.darkGrey.withValues(
                                            alpha: .2,
                                          ),
                                          blurRadius: 1.0,
                                          // spreadRadius: 1.0,
                                          offset: const Offset(0.0, 3.0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 6,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Category Image
                                          Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: categoryColor.withValues(
                                                alpha: .08,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: isLoading
                                                  ? const SizedBox.shrink()
                                                  : Image.network(
                                                      '${ApiRoutes.baseUrl}${category.categoryImage ?? ''}',
                                                      height: isFurniture
                                                          ? 35
                                                          : 30,
                                                      width: isFurniture
                                                          ? 35
                                                          : 30,
                                                      fit: BoxFit.contain,
                                                      filterQuality:
                                                          FilterQuality.high,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Icon(
                                                              Icons
                                                                  .category_outlined,
                                                              size: 27,
                                                              color:
                                                                  categoryColor,
                                                            );
                                                          },
                                                    ),
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          // Category Name
                                          BodyTextColors(
                                            title:
                                                category.categoryName
                                                    ?.capitalize() ??
                                                '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: 50)),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: HeaderTextBlack(
                                title: 'Featured Businesses',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: 6)),
                          SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Container(
                                  width: 160,
                                  height: 2,
                                  margin: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.violet,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: 10)),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 290,
                              child: ListView.builder(
                                itemCount: homeShops.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                itemBuilder: (context, index) {
                                  return ShopCard(shop: homeShops[index]);
                                },
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: 80)),
                          if (shopBanners.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: ShopBannersSlider(
                                shopBanners: shopBanners,
                                height: 180,
                              ),
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 40)),
                          ],
                          SliverToBoxAdapter(
                            child: Container(
                              height: 153,
                              color: Colors.transparent,
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: EndMessageSection(title: 'MAP MAN'),
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
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
    return SizedBox(height: 240, child: Stack(children: []));
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
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      leading: GestureDetector(
        onTap: () {
          homeController.setCurrentPage = 3;
        },
        child: SizedBox(
          height: 42,
          width: 42,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(50),
            child: CustomNetworkImage(isProfile: true, imageUrl: profileImage),
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
        shop.shopImage ?? shop.image1 ?? ApiRoutes.defaultShopImageUrl;

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

    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRoutes.shopDetail, extra: shop.id ?? 0);
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 14, bottom: 12, top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.whiteText,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withValues(alpha: .1),
              spreadRadius: 1,
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: CustomNetworkImage(
                      imageUrl: image.startsWith("http")
                          ? image
                          : "${ApiRoutes.baseUrl}$image",
                      boxFit: BoxFit.cover,
                    ),
                  ),
                ),

                /// Category Badge
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.whiteText.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.storefront_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        BodyTextColors(
                          title: shop.category?.capitalize() ?? "Shop",
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderTextBlack(
                          title: shop.shopName ?? "Unknown Shop",
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: BodyTextColors(
                                title: shop.address ?? "Address not available",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    /// Open/Closed Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isShopClosed()
                            ? GenericColors.darkRed.withValues(alpha: 0.08)
                            : GenericColors.darkGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isShopClosed()
                                  ? GenericColors.darkRed
                                  : GenericColors.darkGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          BodyTextColors(
                            title: isShopClosed() ? 'Closed Now' : 'Open Now',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isShopClosed()
                                ? GenericColors.darkRed
                                : GenericColors.darkGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShopBannersSlider extends StatefulWidget {
  const ShopBannersSlider({
    super.key,
    required this.shopBanners,
    required this.height,
  });

  final List<ShopBanners> shopBanners;
  final double height;

  @override
  State<ShopBannersSlider> createState() => _ShopBannersSliderState();
}

class _ShopBannersSliderState extends State<ShopBannersSlider> {
  int _currentIndex = 0;

  String _getImageUrl(String image) {
    if (image.startsWith('https')) {
      return image;
    }

    return '${ApiRoutes.baseUrl}$image';
  }

  void _openShopDetails(int shopId) {
    context.pushNamed(AppRoutes.shopDetail, extra: shopId);
  }

  Color _parseColor(String? hexString, Color defaultColor) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    final buffer = StringBuffer();
    final hex = hexString.replaceFirst('#', '');
    if (hex.length == 6) {
      buffer.write('FF');
    }
    buffer.write(hex);
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return defaultColor;
    }
  }

  Gradient _parseGradient(String? hexString, Color defaultColor) {
    if (hexString == null || hexString.isEmpty) {
      return LinearGradient(colors: [defaultColor, defaultColor]);
    }
    final parts = hexString.split(',');
    List<Color> colors = [];
    for (var part in parts) {
      final hex = part.trim().replaceFirst('#', '');
      final buffer = StringBuffer();
      if (hex.length == 6) {
        buffer.write('FF');
      }
      buffer.write(hex);
      try {
        colors.add(Color(int.parse(buffer.toString(), radix: 16)));
      } catch (e) {
        colors.add(defaultColor);
      }
    }
    if (colors.isEmpty) {
      return LinearGradient(colors: [defaultColor, defaultColor]);
    } else if (colors.length == 1) {
      return LinearGradient(colors: [colors.first, colors.first]);
    }
    return LinearGradient(colors: colors);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shopBanners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CarouselSlider(
          items: widget.shopBanners.map((banner) {
            final int shopId = banner.shopId ?? 0;
            final headerColor = _parseColor(banner.fontColor, Colors.white);
            final descColor = _parseColor(
              banner.fontColor,
              Colors.white.withValues(alpha: 0.92),
            );
            final btnBgGradient = _parseGradient(
              banner.backgroundColor,
              AppColors.primary,
            );

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 2,
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    if (banner.backgroundImage != null &&
                        banner.backgroundImage!.isNotEmpty)
                      IgnorePointer(
                        child: Image.network(
                          banner.backgroundImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: AppColors.primary);
                          },
                        ),
                      )
                    else
                      Container(color: AppColors.primary),
                    if (banner.image != null && banner.image!.isNotEmpty)
                      InkWell(
                        onTap: () => _openShopDetails(shopId),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CustomNetworkImage(
                            imageUrl: _getImageUrl(banner.image!),
                            boxFit: BoxFit.cover,
                          ),
                        ),
                      ),
                    // Content
                    InkWell(
                      onTap: () => _openShopDetails(shopId),
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (banner.shopName != null &&
                                banner.shopName.toString().trim().isNotEmpty)
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteText,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(5),
                                    child: Image.asset(
                                      AppIcons.shopP,
                                      height: 13,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    banner.shopName.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.whiteText,
                                    ),
                                  ),
                                ],
                              ),
                            const Spacer(),
                            if (banner.headerText != null &&
                                banner.headerText
                                    .toString()
                                    .trim()
                                    .isNotEmpty) ...[
                              SizedBox(height: 5),
                              Text(
                                banner.headerText.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.getFont(
                                  banner.font ?? 'Roboto',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: headerColor,
                                ),
                              ),
                            ],
                            SizedBox(height: 10),
                            if (banner.description != null &&
                                banner.description
                                    .toString()
                                    .trim()
                                    .isNotEmpty) ...[
                              BodyTextColors(
                                title: banner.description.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                color: descColor,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w400,
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (banner.cta != null &&
                                banner.cta.toString().trim().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: btnBgGradient,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.20),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    BodyTextColors(
                                      title: banner.cta.toString(),
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: widget.height + 16,
            viewportFraction: 0.95,
            autoPlay: widget.shopBanners.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 700),
            autoPlayCurve: Curves.easeOutCubic,
            enlargeCenterPage: true,
            enlargeFactor: 0.06,
            enableInfiniteScroll: widget.shopBanners.length > 1,
            onPageChanged: (index, reason) {
              if (!mounted) return;
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),

        // Page indicator
        Positioned(
          bottom: 15,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: CustomIndicator(
              currentIndex: _currentIndex,
              itemCount: widget.shopBanners.length,
              activeWidth: 18,
              inactiveWidth: 6,
              borderHeight: 4,
            ),
          ),
        ),
      ],
    );
  }
}
