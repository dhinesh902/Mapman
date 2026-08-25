import 'package:flutter/material.dart';
import 'package:flutter_scratch_card/flutter_scratch_card.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:mapman/controller/offer_controller.dart';
import 'package:mapman/model/offers_model.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_containers.dart';

class AllOffersPage extends StatefulWidget {
  const AllOffersPage({super.key});

  @override
  State<AllOffersPage> createState() => _AllOffersPageState();
}

class _AllOffersPageState extends State<AllOffersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferController>().fetchAllOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            const ActionBar(title: 'All Offers'),
            Flexible(
              child: Consumer<OfferController>(
                builder: (context, controller, _) {
                  switch (controller.allOffersData.status) {
                    case Status.INITIAL:
                    case Status.LOADING:
                      return const CustomLoadingIndicator();
                    case Status.COMPLETED:
                      final offers = controller.allOffersData.data ?? [];
                      if (offers.isEmpty) {
                        return const EmptyDataContainer(
                          children: [
                            Icon(
                              Icons.local_offer,
                              size: 80,
                              color: GenericColors.darkAmber,
                            ),
                            SizedBox(height: 20),
                            BodyTextHint(
                              title: 'No Offers Available',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          final List<List<Color>> cardGradients = List.generate(
                            Colors.primaries.length,
                            (index) => [
                              Colors.primaries[index],
                              Colors.primaries[index].shade300,
                            ],
                          );
                          return GestureDetector(
                            onTap: () {
                              if (offer.isOpened == true) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                      body: RewardPageWidget(offer: offer),
                                    ),
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) =>
                                      ScratchRewardDialog(offer: offer),
                                );
                              }
                            },
                            child: Builder(
                              builder: (context) {
                                if (offer.isOpened == true) {
                                  final baseColor =
                                      cardGradients[index %
                                              cardGradients.length]
                                          .first;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: baseColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: -20,
                                          right: -20,
                                          child: Icon(
                                            Icons.stars_rounded,
                                            size: 140,
                                            color: baseColor.withValues(
                                              alpha: 0.08,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children:
                                                offer.openStatus == 'opened'
                                                ? [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: baseColor
                                                                .withValues(
                                                                  alpha: 0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: BodyTextColors(
                                                            title: "CLAIMED",
                                                            color: baseColor,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.check_circle,
                                                          color: baseColor,
                                                          size: 24,
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        BodyTextColors(
                                                          title:
                                                              offer
                                                                  .offerPercentage ??
                                                              '',
                                                          color: Colors.black87,
                                                          fontSize: 34,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        BodyTextColors(
                                                          title:
                                                              offer
                                                                  .offerTitle ??
                                                              '',
                                                          color: Colors.black54,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ]
                                                : [
                                                    Expanded(
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    12,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: baseColor
                                                                    .withValues(
                                                                      alpha:
                                                                          0.1,
                                                                    ),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .touch_app_rounded,
                                                                color:
                                                                    baseColor,
                                                                size: 32,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 12,
                                                            ),
                                                            BodyTextColors(
                                                              title:
                                                                  "${offer.offerTitle?.capitalize()}",
                                                              color: baseColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              cardGradients[index %
                                                      cardGradients.length]
                                                  .first
                                                  .withValues(alpha: 0.4),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.asset(AppIcons.cardP),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    case Status.ERROR:
                      return CustomErrorTextWidget(
                        title:
                            controller.allOffersData.message ??
                            'An error occurred',
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfferItemCard extends StatelessWidget {
  final OffersData offer;

  const OfferItemCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final offerDetails = offer.offerDetails ?? [];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: HeaderTextBlack(
                  title: offer.offerTitle ?? 'Unknown Offer',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (offer.offerPercentage != null &&
                  offer.offerPercentage!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: BodyTextColors(
                    title: offer.offerPercentage!,
                    color: AppColors.whiteText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          if (offer.offerExpiry != null && offer.offerExpiry!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.timer,
                  size: 16,
                  color: AppColors.lightGreyHint,
                ),
                const SizedBox(width: 5),
                BodyTextHint(
                  title: 'Expires: ${offer.offerExpiry}',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ],
          if (offerDetails.isNotEmpty) ...[
            const SizedBox(height: 15),
            const BodyTextColors(
              title: 'Details:',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
            const SizedBox(height: 5),
            ...offerDetails.map(
              (detail) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BodyTextColors(
                      title: '• ',
                      color: AppColors.darkText,
                      fontSize: 12,
                    ),
                    Expanded(
                      child: BodyTextColors(
                        title: detail,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ScratchRewardDialog extends StatefulWidget {
  final OffersData offer;

  const ScratchRewardDialog({super.key, required this.offer});

  @override
  State<ScratchRewardDialog> createState() => _ScratchRewardDialogState();
}

class _ScratchRewardDialogState extends State<ScratchRewardDialog> {
  bool isExpanded = false;
  bool showReward = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onScratchCompleted() async {
    if (isExpanded) return;

    // Update locally so it reflects immediately without waiting for API
    widget.offer.isOpened = true;
    widget.offer.openStatus = 'opened';

    // Call offerStatusOpen when scratched
    if (widget.offer.id != null) {
      context.read<OfferController>().offerStatusOpen(
        offerId: widget.offer.id!,
      );
    }

    setState(() {
      isExpanded = true;
    });

    // Wait for AnimatedContainer to finish
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      showReward = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: AppColors.whiteText,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 0 : 24,
        vertical: isExpanded ? 0 : 80,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
        width: isExpanded ? screen.width : 200,
        height: isExpanded ? screen.height : 260,
        decoration: BoxDecoration(
          color: AppColors.whiteText,
          borderRadius: BorderRadius.circular(isExpanded ? 0 : 28),
          boxShadow: isExpanded
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 8,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        clipBehavior: Clip.hardEdge,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: showReward
              ? RewardPageWidget(offer: widget.offer)
              : ScratchCard(
                  key: const ValueKey('scratch_card'),
                  overlayImageAsset: "assets/images/png/card.jpg",
                  animationType: ScratchAnimationType.lottie,
                  animationAsset: "assets/lottie/confetti.json",
                  progressTriggers: const [0.5],
                  autoReveal: true,
                  threshold: 0.6,
                  onThreshold: _onScratchCompleted,
                  child: Container(
                    alignment: Alignment.center,
                    color: AppColors.whiteText,
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                GenericColors.darkAmber.withValues(alpha: .5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GenericColors.darkAmber.withValues(
                                  alpha: .5,
                                ),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              height: 62,
                              width: 62,
                              decoration: const BoxDecoration(
                                color: AppColors.whiteText,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.card_giftcard_rounded,
                                size: 32,
                                color: GenericColors.darkAmber.withValues(
                                  alpha: .5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: GenericColors.darkAmber.withValues(
                              alpha: .5,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: GenericColors.darkAmber.withValues(
                                alpha: .5,
                              ),
                            ),
                          ),
                          child: const BodyTextColors(
                            title: "Scratch to reveal offers!",
                            textAlign: TextAlign.center,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: GenericColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class RewardPageWidget extends StatelessWidget {
  final OffersData offer;

  const RewardPageWidget({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final offerDetails = offer.offerDetails ?? [];
    return Container(
      key: const ValueKey('reward_page'),
      color: AppColors.scaffoldBackground,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [GenericColors.homeTopPrimary, AppColors.primary],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // AppBar replacement
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: AppColors.whiteText.withValues(alpha: 0.2),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.whiteText,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const BodyTextColors(
                        title: "Congratulations!",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteText,
                      ),
                      const SizedBox(width: 40), // Balance the row
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 35,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.whiteText,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: GenericColors.lightOrange.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: GenericColors.lightOrange,
                              size: 56,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const BodyTextColors(
                            title: "YOU'VE UNLOCKED",
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGrey,
                            letterSpacing: 1.5,
                          ),
                          const SizedBox(height: 12),
                          BodyTextColors(
                            title: offer.offerPercentage ?? "Exclusive",
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkText,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          BodyTextColors(
                            title: offer.offerTitle ?? "Special Offer",
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.bgGrey, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const BodyTextColors(
                            title: "HOW IT WORKS",
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGrey,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.bgGrey, thickness: 1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Details
                    ...offerDetails.map((detail) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: GenericColors.lightOrange,
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: BodyTextColors(
                                title: detail,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightDarkText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Expiry
                    if (offer.offerExpiry != null &&
                        offer.offerExpiry!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: GenericColors.placeHolderGrey.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.darkGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: BodyTextColors(
                                title: "Valid until ${offer.offerExpiry}",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Button
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: CustomFullButton(
                    title: 'View shop details',
                    isDialogue: true,
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.shopDetail,
                        extra: offer.shopId ?? 0,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
