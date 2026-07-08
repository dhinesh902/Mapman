import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/shop_detail_model.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mapman/views/widgets/skeleton_widgets.dart';
import 'package:provider/provider.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  late ProfileController profileController;

  @override
  void initState() {
    // TODO: implement initState
    profileController = context.read<ProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getShopList();
    });
    super.initState();
  }

  Future<void> getShopList() async {
    final response = await profileController.getShopList();
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
    profileController = context.watch<ProfileController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(
          title: 'Listings',
          action: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                context.pushNamed(AppRoutes.registerShopDetail);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, GenericColors.homeTopPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_business_rounded,
                      size: 18,
                      color: AppColors.whiteText,
                    ),
                    const SizedBox(width: 6),
                    const BodyTextColors(
                      title: 'Add',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Builder(
          builder: (context) {
            final isLoading =
                profileController.shopListData.status == Status.INITIAL ||
                profileController.shopListData.status == Status.LOADING;

            if (profileController.shopListData.status == Status.ERROR) {
              return CustomErrorTextWidget(
                title: '${profileController.shopListData.message}',
              );
            }

            final shopList = profileController.shopListData.data ?? [];

            if (shopList.isEmpty && !isLoading) {
              return EmptyDataContainer(
                children: [
                  Image.asset(AppIcons.shopP, height: 130, width: 130),
                  const SizedBox(height: 20),
                  BodyTextColors(
                    title: 'You don\'t have any shops yet.',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.center,
                    color: AppColors.lightGreyHint,
                  ),
                ],
              );
            }

            return Skeletonizer(
              enabled: isLoading,
              child: isLoading
                  ? const ShopListSkeleton()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      itemCount: shopList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ProfessionalShopCard(
                            shopDetailData: shopList[index],
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

class ProfessionalShopCard extends StatefulWidget {
  const ProfessionalShopCard({super.key, required this.shopDetailData});

  final ShopDetailData shopDetailData;

  @override
  State<ProfessionalShopCard> createState() => _ProfessionalShopCardState();
}

class _ProfessionalShopCardState extends State<ProfessionalShopCard> {
  Future<void> deleteShop({required int shopId}) async {
    CustomDialogues.showLoadingDialogue(context);
    final response = await context.read<ProfileController>().deleteShop(
      shopId: shopId,
    );
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    if (response.status == Status.COMPLETED) {
      await CustomDialogues().showDeleteDialog(
        context,
        body: 'Shop deleted successfully',
      );
      if (!mounted) return;
      await context.read<ProfileController>().getShopList();
    } else {
      ExceptionHandler.handleUiException(
        context: context,
        status: response.status,
        message: response.message,
      );
    }
  }

  // void _handleMenuAction(String value) {
  //   switch (value) {
  //     case 'edit':
  //       context.pushNamed(
  //         AppRoutes.editShopDetail,
  //         extra: widget.shopDetailData,
  //       );
  //       break;
  //     case 'delete':
  //       CustomDialogues().showDeleteConfirmDialog(
  //         context,
  //         onTap: () async {
  //           await deleteShop(shopId: widget.shopDetailData.id ?? 0);
  //         },
  //       );
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.editShopDetail,
          extra: widget.shopDetailData,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CustomNetworkImage(
                    imageUrl: widget.shopDetailData.shopImage ?? '',
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: BodyTextColors(
                      title:
                          widget.shopDetailData.category?.capitalize() ??
                          'Store',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () async {
                      CustomDialogues().showDeleteConfirmDialog(
                        context,
                        onTap: () async {
                          await deleteShop(
                            shopId: widget.shopDetailData.id ?? 0,
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(AppIcons.deleteFill),
                    ),
                  ),
                ),
                // Positioned(
                //   top: 12,
                //   right: 12,
                //   child: Container(
                //     height: 36,
                //     width: 36,
                //     decoration: BoxDecoration(
                //       color: AppColors.darkText.withValues(alpha: 0.3),
                //       shape: BoxShape.circle,
                //     ),
                //     child: PopupMenuButton<String>(
                //       padding: EdgeInsets.zero,
                //       icon: const Icon(
                //         Icons.more_vert_rounded,
                //         color: Colors.white,
                //         size: 20,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(16),
                //       ),
                //       color: Colors.white,
                //       elevation: 8,
                //       offset: const Offset(0, 40),
                //       onSelected: _handleMenuAction,
                //       itemBuilder: (BuildContext context) => [
                //         PopupMenuItem(
                //           value: 'edit',
                //           child: Row(
                //             children: [
                //               Container(
                //                 padding: const EdgeInsets.all(6),
                //                 decoration: BoxDecoration(
                //                   color: AppColors.primary.withValues(alpha: 0.1),
                //                   shape: BoxShape.circle,
                //                 ),
                //                 child: const Icon(
                //                   Icons.edit_rounded,
                //                   color: AppColors.primary,
                //                   size: 16,
                //                 ),
                //               ),
                //               const SizedBox(width: 12),
                //               const BodyTextColors(
                //                 title: 'Edit Shop',
                //                 fontSize: 14,
                //                 fontWeight: FontWeight.w600,
                //                 color: AppColors.darkText,
                //               ),
                //             ],
                //           ),
                //         ),
                //         PopupMenuItem(
                //           value: 'delete',
                //           child: Row(
                //             children: [
                //               Container(
                //                 padding: const EdgeInsets.all(6),
                //                 decoration: BoxDecoration(
                //                   color: Colors.redAccent.withValues(alpha: 0.1),
                //                   shape: BoxShape.circle,
                //                 ),
                //                 child: const Icon(
                //                   Icons.delete_outline_rounded,
                //                   color: Colors.redAccent,
                //                   size: 16,
                //                 ),
                //               ),
                //               const SizedBox(width: 12),
                //               const BodyTextColors(
                //                 title: 'Delete Shop',
                //                 fontSize: 14,
                //                 fontWeight: FontWeight.w600,
                //                 color: Colors.redAccent,
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: BodyTextColors(
                    title: widget.shopDetailData.shopName?.capitalize() ?? '',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.access_time_filled_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BodyTextColors(
                              title: 'Business Hours',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                            BodyTextColors(
                              title:
                                  '${widget.shopDetailData.openTime ?? 'N/A'} - ${widget.shopDetailData.closeTime ?? 'N/A'}',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info Row: Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BodyTextColors(
                              title: 'Location',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                            BodyTextColors(
                              title:
                                  widget.shopDetailData.address ??
                                  'Not provided',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkGrey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (widget.shopDetailData.description != null &&
                      widget.shopDetailData.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFEEEEEE), height: 1),
                    const SizedBox(height: 16),
                    BodyTextColors(
                      title: 'About',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                    const SizedBox(height: 6),
                    BodyTextColors(
                      title: widget.shopDetailData.description!,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGrey,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
