import 'package:flutter/material.dart';
import 'package:flutter_scratch_card/flutter_scratch_card.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/images.dart';
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          final List<List<Color>> premiumGradients = [
                            [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
                            [const Color(0xFFF5576C), const Color(0xFFF093FB)],
                            [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
                            [const Color(0xFFFA709A), const Color(0xFFFEE140)],
                            [const Color(0xFF30CFD0), const Color(0xFF330867)],
                            [const Color(0xFFFF512F), const Color(0xFFDD2476)],
                            [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
                            [const Color(0xFFFC5C7D), const Color(0xFF6A82FB)],
                            [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                            [const Color(0xFFFF8008), const Color(0xFFFFC837)],
                            [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
                            [const Color(0xFFED213A), const Color(0xFF93291E)],
                            [const Color(0xFF2193B0), const Color(0xFF6DD5ED)],
                            [const Color(0xFFB721FF), const Color(0xFF21D4FD)],
                            [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
                          ];
                          final gradient = premiumGradients[index % premiumGradients.length];

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
                                  builder: (_) => ScratchRewardDialog(offer: offer),
                                );
                              }
                            },
                            child: Builder(
                              builder: (context) {
                                if (offer.isOpened == true) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: gradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: gradient.first.withValues(alpha: 0.35),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Stack(
                                      children: [
                                        // Background decorative icon
                                        Positioned(
                                          right: -20,
                                          bottom: -20,
                                          child: Icon(
                                            Icons.card_giftcard_rounded,
                                            size: 110,
                                            color: Colors.white.withValues(alpha: 0.15),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Top row: Status
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.25),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: const Text(
                                                      "CLAIMED",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w800,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                              
                                              // Bottom content: Percentage and Title
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    offer.offerPercentage ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 34,
                                                      fontWeight: FontWeight.w900,
                                                      height: 1.1,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    offer.offerTitle ?? '',
                                                    style: TextStyle(
                                                      color: Colors.white.withValues(alpha: 0.95),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.2,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // Unopened State
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: gradient.first.withValues(alpha: 0.35),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          AppIcons.cardP,
                                          fit: BoxFit.cover,
                                        ),
                                        // Subtle overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(alpha: 0.6),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.touch_app_rounded,
                                                color: Colors.white,
                                                size: 38,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Tap to open",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
          // Elegant top background with a sleek curve
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    GenericColors.homeTopPrimary,
                    AppColors.primary,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  // Subtle overlay glow effects
                  Positioned(
                    top: -60,
                    right: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // Custom AppBar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 24,
                        ),
                      ),
                      const Text(
                        "Reward Unlocked",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the row
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Premium Reward Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [GenericColors.darkYellow, GenericColors.lightOrange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: GenericColors.lightOrange.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                              size: 46,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "CONGRATULATIONS",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.black38,
                              letterSpacing: 2.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            offer.offerPercentage ?? "Exclusive",
                            style: const TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              height: 1.1,
                              letterSpacing: -1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            offer.offerTitle ?? "Special Offer",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: 0.6),
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Stylish Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "HOW TO USE",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade500,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Offer Details
                    if (offerDetails.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: offerDetails.asMap().entries.map((entry) {
                            final bool isLast = entry.key == offerDetails.length - 1;
                            return Padding(
                              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: GenericColors.lightGreen.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: GenericColors.darkGreen,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    // Expiry
                    if (offer.offerExpiry != null && offer.offerExpiry!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: GenericColors.lightOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: GenericColors.lightOrange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              color: GenericColors.darkAmber,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Valid until ${offer.offerExpiry}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom Action Button
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: CustomFullButton(
                    title: 'View Shop Details',
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
