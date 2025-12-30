import 'dart:io';

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
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
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
      context.read<ProfileController>().getShopDetail();
    });
    super.initState();
  }

  final List<Map<String, dynamic>> homeBanners = [
    {
      "banner": AppIcons.happyBgP,
      "title": "Boost Your shop’s",
      "body": "Best and Affordable way to get new customers",
      "image": AppIcons.happyP,
    },
    {
      "banner": AppIcons.happyBg1P,
      "title": "Upload Video & Promote",
      "body": "Best and Affordable way to get new customers",
      "image": AppIcons.happy1p,
    },
  ];

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
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        return true;
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      final result = await Permission.notification.request();

      if (result.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return result.isGranted;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    homeController = context.watch<HomeController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: Builder(
        builder: (context) {
          switch (homeController.homeData.status) {
            case Status.INITIAL:
              return CustomLoadingIndicator();
            case Status.LOADING:
              return CustomLoadingIndicator();
            case Status.COMPLETED:
              final categories = homeController.homeCategories;
              return Column(
                children: [
                  HomeTopCard(
                    homeBanners: homeBanners,
                    homeController: homeController,
                    homeData: homeController.homeData.data ?? HomeData(),
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                            return GestureDetector(
                              onTap: () {
                                homeController.setCurrentPage = 1;
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
                                            child: Image.network(
                                              '${ApiRoutes.baseUrl}${categories[index].categoryImage ?? ''}',
                                              height: 40,
                                              width: 40,
                                              filterQuality: FilterQuality.high,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),

                                      Container(
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.scaffoldBackground,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                bottom: Radius.circular(6),
                                              ),
                                        ),
                                        child: Center(
                                          child: BodyTextColors(
                                            title:
                                                categories[index].categoryName
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .18,
                        ),
                        BottomCarousalSlider(
                          images: [""],
                          homeController: homeController,
                          height: 74,
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
              );
            case Status.ERROR:
              return CustomErrorTextWidget(
                title: '${homeController.homeData.message}',
              );
          }
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

  final List<Map<String, dynamic>> homeBanners;
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
                CarouselSlider(
                  items: List.generate(homeBanners.length, (index) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(2, 0, 0, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(homeBanners[index]['banner']),
                          fit: BoxFit.cover,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  BodyTextColors(
                                    title: homeBanners[index]['title'],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.whiteText,
                                  ),
                                  SizedBox(height: 10),
                                  BodyTextColors(
                                    title: homeBanners[index]['body'],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w200,
                                    color: AppColors.whiteText,
                                  ),
                                  SizedBox(height: 15),
                                  InkWell(
                                    onTap: () {
                                      CustomDialogues().showRatingDialog(
                                        context,
                                      );
                                    },
                                    child: Container(
                                      height: 28,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: index == 1
                                            ? AppColors.darkText
                                            : AppColors.primary,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: BodyTextColors(
                                          title: 'Contact Now',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.whiteText,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Image.asset(
                              homeBanners[index]['image'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  options: CarouselOptions(
                    height: 155,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    enlargeFactor: 0.3,
                    autoPlayInterval: Duration(seconds: 2),
                    enlargeCenterPage: false,
                    enableInfiniteScroll: true,
                    pageSnapping: true,
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
                context.pushNamed(AppRoutes.savedVideos);
              },
              child: Image.asset(AppIcons.bookmarkP, height: 30),
            ),
            SizedBox(width: 15),
            CircleContainer(
              onTap: () {
                context.pushNamed(AppRoutes.notifications);
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: SvgPicture.asset(AppIcons.notification),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
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
                                    '${homeController.notificationCountResponse.data ?? 0}',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                textAlign: TextAlign.center,
                                color: AppColors.whiteText,
                              );
                            case Status.ERROR:
                              return BodyTextColors(
                                title: '0',
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
  const CircleContainer({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          shape: BoxShape.circle,
        ),
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

  final List<String> images;
  final HomeController homeController;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Stack(
        children: [
          CarouselSlider(
            items: List.generate(images.length, (index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: AssetImage(AppIcons.beerBgP),
                    fit: BoxFit.cover,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 15),
                  title: BodyTextColors(
                    title: 'Near by Wine shop',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteText,
                  ),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 28,
                        width: 88,
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkText,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: BodyTextColors(
                            title: 'Explore Now',
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: AppColors.whiteText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Image.asset(
                    AppIcons.beerManP,
                    height: 73,
                    width: 77,
                  ),
                ),
              );
            }),
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              autoPlay: false,
              enlargeFactor: 0.3,
              autoPlayInterval: Duration(seconds: 2),
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
