import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapman/model/offers_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/views/main_dashboard/profile/banner_offers/make_your_offer.dart';
import 'package:mapman/views/main_dashboard/video/videos.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/skeleton_widgets.dart';
import 'package:mapman/views/widgets/category_chip_selection.dart';
import 'package:mapman/controller/offer_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/shop_detail_model.dart';
import 'package:provider/provider.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/utils/handlers/api_exception.dart';

class BannersOffers extends StatefulWidget {
  const BannersOffers({super.key});

  @override
  State<BannersOffers> createState() => _BannersOffersState();
}

class _BannersOffersState extends State<BannersOffers> {
  final ValueNotifier<int> tabNotifier = ValueNotifier(0);
  final ValueNotifier<ShopDetailData?> selectedShopNotifier = ValueNotifier(
    null,
  );

  late OfferController offerController;
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    offerController = context.read<OfferController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      profileController = context.read<ProfileController>();
      final offerController = context.read<OfferController>();

      final res = await profileController.getShopList();
      if (res.status == Status.COMPLETED &&
          res.data != null &&
          res.data!.isNotEmpty) {
        selectedShopNotifier.value = res.data!.first;
        offerController.getShopBanners(shopId: res.data!.first.id ?? 0);
        offerController.getShopOffers(shopId: res.data!.first.id ?? 0);
      }
    });
  }

  @override
  void dispose() {
    tabNotifier.dispose();
    selectedShopNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    offerController = context.watch<OfferController>();
    profileController = context.watch<ProfileController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: ValueListenableBuilder(
        valueListenable: tabNotifier,
        builder: (context, value, child) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      GenericColors.bannerBlue1,
                      GenericColors.bannerBlue2,
                      GenericColors.bannerBlue3,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(AppIcons.discountP, height: 35, width: 35),
                        SizedBox(width: 10),
                        BodyTextColors(
                          title: "Banners & Offers",
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteText,
                        ),
                        Spacer(),
                        OutlinedButton(
                          onPressed: () {
                            if (value == 0) {
                              context.pushNamed(AppRoutes.makeYourOwnBanner);
                            } else {
                              context.pushNamed(AppRoutes.makeYourOffer);
                            }
                          },
                          style: ButtonStyle(
                            side: WidgetStatePropertyAll(
                              BorderSide(color: AppColors.whiteText, width: 1),
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(5),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.create,
                                height: 14,
                                width: 14,
                              ),
                              SizedBox(width: 5),
                              BodyTextColors(
                                title: "Create",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.whiteText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.bgGrey,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: VideoHeadingContainer(
                              title: 'My Banners',
                              icon: AppIcons.adsP,
                              isActive: value == 0,
                              isLeft: true,
                              isVideo: true,
                              onTap: () async {
                                tabNotifier.value = 0;
                              },
                            ),
                          ),
                          Expanded(
                            child: VideoHeadingContainer(
                              title: 'My Offers',
                              icon: AppIcons.offerP,
                              isActive: value == 1,
                              isLeft: false,
                              isVideo: true,
                              onTap: () async {
                                tabNotifier.value = 1;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    ValueListenableBuilder<ShopDetailData?>(
                      valueListenable: selectedShopNotifier,
                      builder: (context, selectedShop, child) {
                        final profileController = context
                            .watch<ProfileController>();
                        final items = profileController.shopListData.data ?? [];

                        ShopDetailData? validValue;
                        if (selectedShop != null) {
                          if (items.contains(selectedShop)) {
                            validValue = selectedShop;
                          } else {
                            try {
                              validValue = items.firstWhere(
                                (e) => e.id == selectedShop.id,
                              );
                            } catch (_) {}
                          }
                        }

                        return CustomShopDropdown<ShopDetailData>(
                          hintText:
                              profileController.shopListData.status ==
                                  Status.LOADING
                              ? "Loading shops..."
                              : "Select Shop",
                          value: validValue,
                          items: items,
                          itemLabel: (shop) => shop.shopName ?? "Unknown Shop",
                          onChanged: (value) {
                            if (value != null) {
                              selectedShopNotifier.value = value;
                              context.read<OfferController>().getShopBanners(
                                shopId: value.id ?? 0,
                              );
                              context.read<OfferController>().getShopOffers(
                                shopId: value.id ?? 0,
                              );
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              Flexible(
                child: Builder(
                  builder: (context) {
                    if (value == 0) {
                      if (offerController.bannerData.status == Status.LOADING ||
                          offerController.bannerData.status == Status.INITIAL ||
                          profileController.shopListData.status ==
                              Status.LOADING) {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            ListView.builder(
                              itemCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                return const OfferCardSkeleton();
                              },
                            ),
                          ],
                        );
                      }
                      if (offerController.bannerData.status == Status.ERROR) {
                        return CustomErrorTextWidget(
                          title: '${offerController.bannerData.message}',
                        );
                      }
                      final banners = offerController.bannerData.data ?? [];
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          banners.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: NoDataText(title: "No data found"),
                                )
                              : ListView.builder(
                                  itemCount: banners.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final banner = banners[index];
                                    return OfferCard(
                                      banner: banner,
                                      onEdit: () {
                                        final type =
                                            banner.bannerType?.toLowerCase() ??
                                            '';
                                        if (type == 'image') {
                                          context.pushNamed(
                                            AppRoutes.uploadMakeYourOwnBanner,
                                            extra: banner,
                                          );
                                        } else {
                                          context.pushNamed(
                                            AppRoutes.createMakeYourOwnBanner,
                                            extra: banner,
                                          );
                                        }
                                      },
                                      onDelete: () {
                                        CustomDialogues().showDeleteConfirmDialog(
                                          context,
                                          title: 'Delete Banner',
                                          body:
                                              'Are you sure you want to delete this banner?',
                                          onTap: () async {
                                            CustomDialogues.showLoadingDialogue(
                                              context,
                                            );
                                            final response = await context
                                                .read<OfferController>()
                                                .deleteBanner(
                                                  bannerId: banner.id ?? 0,
                                                  shopId: banner.shopId ?? 0,
                                                );
                                            if (!context.mounted) return;
                                            Navigator.of(context).pop();

                                            if (selectedShopNotifier.value !=
                                                null) {
                                              await context
                                                  .read<OfferController>()
                                                  .getShopBanners(
                                                    shopId:
                                                        selectedShopNotifier
                                                            .value!
                                                            .id ??
                                                        0,
                                                  );
                                            }

                                            if (!context.mounted) return;
                                            if (response.status ==
                                                Status.COMPLETED) {
                                              CustomDialogues().showDeleteDialog(
                                                context,
                                                body:
                                                    'Banner permanently deleted by you',
                                              );
                                            } else {
                                              ExceptionHandler.handleUiException(
                                                context: context,
                                                status: response.status,
                                                message: response.message,
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GradientOutlineButton(
                              title: "Create New Banner",
                              onPressed: () {
                                context.pushNamed(AppRoutes.makeYourOwnBanner);
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    if (value == 1) {
                      if (offerController.offerData.status == Status.LOADING ||
                          offerController.offerData.status == Status.INITIAL ||
                          profileController.shopListData.status ==
                              Status.LOADING) {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            ListView.builder(
                              itemCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                return const OfferCardSkeleton();
                              },
                            ),
                          ],
                        );
                      }
                      if (offerController.offerData.status == Status.ERROR) {
                        return CustomErrorTextWidget(
                          title: '${offerController.offerData.message}',
                        );
                      }

                      final offers = offerController.offerData.data ?? [];

                      return ListView(
                        shrinkWrap: true,
                        children: [
                          offers.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: NoDataText(title: "No data found"),
                                )
                              : ListView.builder(
                                  itemCount: offers.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final offer = offers[index];
                                    final colors = [
                                      Colors.primaries[index %
                                          Colors.primaries.length],
                                      Colors
                                          .primaries[index %
                                              Colors.primaries.length]
                                          .shade300,
                                    ];
                                    return ScratchCardWidget(
                                      title: offer.offerTitle ?? "Offer Title",
                                      colors: colors,
                                      expiry:
                                          offer.offerExpiry ??
                                          "Expired in 7 days",
                                      buttonText:
                                          "${offer.offerPercentage} Offer Claim",
                                      actionText: "View Scratch card",
                                      onView: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                      ),
                                                  child: GradientTicketWidget(
                                                    title:
                                                        offer.offerTitle ??
                                                        "Offer Title",
                                                    percentage:
                                                        offer.offerPercentage ??
                                                        "0%",
                                                    shopName:
                                                        selectedShopNotifier
                                                            .value
                                                            ?.shopName ??
                                                        "Unknown Shop",
                                                    offerDetails:
                                                        offer.offerDetails ??
                                                        [],
                                                    termsAndConditions:
                                                        offer
                                                            .termsAndConditions ??
                                                        [],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      onEdit: () {
                                        context.pushNamed(
                                          AppRoutes.makeYourOffer,
                                          extra: offer,
                                        );
                                      },
                                      onDelete: () {
                                        CustomDialogues().showDeleteConfirmDialog(
                                          context,
                                          title: 'Delete Offer',
                                          body:
                                              'Are you sure you want to delete this offer?',
                                          onTap: () async {
                                            CustomDialogues.showLoadingDialogue(
                                              context,
                                            );
                                            final response = await context
                                                .read<OfferController>()
                                                .deleteOffer(
                                                  offerId: offer.id ?? 0,
                                                  shopId: offer.shopId ?? 0,
                                                );
                                            if (!context.mounted) return;
                                            Navigator.of(context).pop();

                                            if (selectedShopNotifier.value !=
                                                null) {
                                              await context
                                                  .read<OfferController>()
                                                  .getShopOffers(
                                                    shopId:
                                                        selectedShopNotifier
                                                            .value!
                                                            .id ??
                                                        0,
                                                  );
                                            }

                                            if (!context.mounted) return;
                                            if (response.status ==
                                                Status.COMPLETED) {
                                              CustomDialogues().showDeleteDialog(
                                                context,
                                                body:
                                                    'Offer permanently deleted by you',
                                              );
                                            } else {
                                              ExceptionHandler.handleUiException(
                                                context: context,
                                                status: response.status,
                                                message: response.message,
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GradientOutlineButton(
                              title: "Create New Offer",
                              onPressed: () {
                                if (value == 0) {
                                  context.pushNamed(
                                    AppRoutes.makeYourOwnBanner,
                                  );
                                } else {
                                  context.pushNamed(AppRoutes.makeYourOffer);
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GradientOutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const GradientOutlineButton({
    super.key,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(1),
        margin: EdgeInsets.only(right: 10, bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: const LinearGradient(
            colors: [
              GenericColors.bannerBlue1,
              GenericColors.bannerBlue2,
              GenericColors.bannerBlue3,
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackgroundDark,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppIcons.create,
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(
                  AppColors.darkText,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 10),
              BodyTextColors(
                title: title,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.darkText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final BannerData banner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OfferCard({
    super.key,
    required this.banner,
    this.onEdit,
    this.onDelete,
  });

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

  @override
  Widget build(BuildContext context) {
    final headerColor = _parseColor(banner.fontColor, Colors.white);
    final descColor = _parseColor(banner.fontColor, AppColors.whiteText.withValues(alpha: 0.9));
    final btnBgColor = _parseColor(banner.backgroundColor, Colors.white);

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
      decoration: BoxDecoration(
        color: AppColors.whiteText,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (banner.image != null && banner.image!.isNotEmpty)
                    CustomNetworkImage(imageUrl: banner.image!),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(banner.backgroundImage ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                banner.headerText ?? '',
                                style: GoogleFonts.getFont(
                                  banner.font ?? '',
                                  color: headerColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: BodyTextColors(
                            title: banner.description ?? '',
                            color: descColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (banner.cta != null && banner.cta!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: btnBgColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkText.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: BodyTextColors(
                              title: banner.cta ?? '',
                              color: AppColors.whiteText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    context.pushNamed(AppRoutes.bannerSchedule);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBorder.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: HeaderTextPrimary(
                      title: banner.bannerType?.capitalize() ?? "",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                _ActionButton(
                  icon: Icons.edit_outlined,
                  iconColor: Colors.blueAccent,
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  onTap: onEdit,
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.delete_outline,
                  iconColor: Colors.redAccent,
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
      ),
    );
  }
}

class ScratchCardWidget extends StatelessWidget {
  final String title;
  final String expiry;
  final String buttonText;
  final String actionText;
  final List<Color> colors;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onView;

  const ScratchCardWidget({
    super.key,
    required this.title,
    required this.expiry,
    required this.buttonText,
    required this.actionText,
    required this.colors,
    this.onEdit,
    this.onDelete,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Colored Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors.isNotEmpty ? colors : [Colors.grey, Colors.grey],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          expiry,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkText.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: colors.isNotEmpty
                                ? colors.first
                                : AppColors.darkGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ticket Divider with Cutouts
          SizedBox(
            height: 20,
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: DashedLinePainter(),
                    ),
                  ),
                ),
                Positioned(
                  left: -10,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.scaffoldBackgroundDark,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.scaffoldBackgroundDark,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onView,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            actionText,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                _ActionButton(
                  icon: Icons.edit_outlined,
                  iconColor: Colors.blueAccent,
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  onTap: onEdit,
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.delete_outline,
                  iconColor: Colors.redAccent,
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 6, dashSpace = 4, startX = 0;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
