import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapman/model/shop_detail_model.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/category_chip_selection.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_drop_downs.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:mapman/controller/offer_controller.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/utils/handlers/api_exception.dart';
import 'package:provider/provider.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/model/offers_model.dart';
import 'package:go_router/go_router.dart';

class MakeYourOffer extends StatefulWidget {
  final OfferData? offerData;

  const MakeYourOffer({super.key, this.offerData});

  @override
  State<MakeYourOffer> createState() => _MakeYourOfferState();
}

class _MakeYourOfferState extends State<MakeYourOffer> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;

  final List<TextEditingController> offerControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> termsControllers = [
    TextEditingController(),
  ];

  final List<int> percentages = [5, 10, 15, 20, 25, 30, 40, 50];

  int? selectedPercentage;
  String? selectedExpiry;
  bool isSuccess = false;

  ValueNotifier<ShopDetailData?> selectedShopNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: widget.offerData?.offerTitle ?? "",
    );

    if (widget.offerData != null) {
      final percentageString = widget.offerData!.offerPercentage?.replaceAll(
        "%",
        "",
      );
      if (percentageString != null) {
        selectedPercentage = int.tryParse(percentageString);
      }
      selectedExpiry = widget.offerData!.offerExpiry;

      if (widget.offerData!.offerDetails != null &&
          widget.offerData!.offerDetails!.isNotEmpty) {
        offerControllers.clear();
        for (final detail in widget.offerData!.offerDetails!) {
          offerControllers.add(TextEditingController(text: detail));
        }
      }

      if (widget.offerData!.termsAndConditions != null &&
          widget.offerData!.termsAndConditions!.isNotEmpty) {
        termsControllers.clear();
        for (final term in widget.offerData!.termsAndConditions!) {
          termsControllers.add(TextEditingController(text: term));
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileController = context.read<ProfileController>();
      if (profileController.shopListData.status == Status.COMPLETED &&
          profileController.shopListData.data != null &&
          profileController.shopListData.data!.isNotEmpty) {
        if (widget.offerData != null) {
          try {
            selectedShopNotifier.value = profileController.shopListData.data!
                .firstWhere((shop) => shop.id == widget.offerData!.shopId);
          } catch (e) {
            selectedShopNotifier.value =
                profileController.shopListData.data!.first;
          }
        } else {
          selectedShopNotifier.value =
              profileController.shopListData.data!.first;
        }
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();

    for (final controller in offerControllers) {
      controller.dispose();
    }
    for (final controller in termsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(
          title: widget.offerData != null
              ? "Edit Your Offer"
              : "Make Your Own Offer",
        ),
        body: Builder(
          builder: (context) {
            if (isSuccess) {
              return ListView(
                padding: EdgeInsets.all(15),
                children: [
                  ValueListenableBuilder<ShopDetailData?>(
                    valueListenable: selectedShopNotifier,
                    builder: (context, selectedShop, child) {
                      return GradientTicketWidget(
                        title: titleController.text.isNotEmpty
                            ? titleController.text
                            : "Offer Title",
                        percentage: "${selectedPercentage ?? 0}%",
                        shopName: selectedShop?.shopName ?? "Unknown Shop",
                        offerDetails: offerControllers
                            .map((e) => e.text)
                            .where((t) => t.isNotEmpty)
                            .toList(),
                        termsAndConditions: termsControllers
                            .map((e) => e.text)
                            .where((t) => t.isNotEmpty)
                            .toList(),
                      );
                    },
                  ),
                  SizedBox(height: 40),
                  OutlinedButton(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      side: WidgetStatePropertyAll(
                        BorderSide(color: GenericColors.darkRed),
                      ),
                      minimumSize: WidgetStatePropertyAll(
                        Size(double.maxFinite, 45),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        isSuccess = false;
                      });
                    },
                    child: Center(
                      child: BodyTextColors(
                        title: "Cancel This Order",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GenericColors.darkRed,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomFullButton(
                    title: widget.offerData != null
                        ? "Update This Offer"
                        : "Apply This Offer",
                    isDialogue: true,
                    onTap: () async {
                      Map<String, dynamic> reqData = {
                        if (widget.offerData != null)
                          "offerId": widget.offerData!.id,
                        "shopId": selectedShopNotifier.value?.id ?? 0,
                        "type": widget.offerData != null ? "update" : "add",
                        "offerTitle": titleController.text,
                        "offerPercentage": "${selectedPercentage ?? 0}%",
                        "offerExpiry": selectedExpiry ?? "0days",
                        "offerDetails": offerControllers
                            .map((e) => e.text)
                            .where((t) => t.isNotEmpty)
                            .toList(),
                        "termsAndConditions": termsControllers
                            .map((e) => e.text)
                            .where((t) => t.isNotEmpty)
                            .toList(),
                      };
                      CustomDialogues.showLoadingDialogue(context);
                      final response = await context
                          .read<OfferController>()
                          .manageOffers(data: reqData);
                      if (!context.mounted) return;
                      Navigator.pop(context);

                      if (response.status == Status.COMPLETED) {
                        CustomDialogues.showSuccessDialog(
                          context,
                          title: "Success",
                          body: "Offer created successfully",
                        );
                        Future.delayed(
                          const Duration(milliseconds: 1500),
                          () async {
                            if (context.mounted) context.pop();
                            await context.read<OfferController>().getShopOffers(
                              shopId: selectedShopNotifier.value?.id ?? 0,
                            );
                          },
                        );
                      } else {
                        ExceptionHandler.handleUiException(
                          context: context,
                          status: response.status,
                          message: response.message,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20),
                ],
              );
            }

            return Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  ValueListenableBuilder<ShopDetailData?>(
                    valueListenable: selectedShopNotifier,
                    builder: (context, selectedShop, child) {
                      final profileController = context
                          .watch<ProfileController>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomShopDropdown<ShopDetailData>(
                            hintText:
                                profileController.shopListData.status ==
                                    Status.LOADING
                                ? "Loading shops..."
                                : "Select Shop",
                            value: selectedShop,
                            items: profileController.shopListData.data ?? [],
                            itemLabel: (shop) =>
                                shop.shopName ?? "Unknown Shop",
                            onChanged: (value) {
                              if (value != null) {
                                selectedShopNotifier.value = value;
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          if (selectedShop != null)
                            ShopDetailCard(shopData: selectedShop),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    title: "Offer Title",
                    controller: titleController,
                    hintText: "Eg. Festival Season Sale",
                    inputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter offer title";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  CustomTextFieldContainer(
                    title: "Offer Percentage",
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: percentages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            mainAxisExtent: 42,
                          ),
                      itemBuilder: (context, index) {
                        final isSelected =
                            selectedPercentage == percentages[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              selectedPercentage = percentages[index];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.primary.withValues(alpha: .7),
                                        AppColors.primary,
                                      ],
                                    )
                                  : null,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : GenericColors.borderGrey,
                              ),
                            ),
                            child: BodyTextColors(
                              title: "${percentages[index]}%",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.whiteText
                                  : AppColors.darkGrey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  CustomDropDownField(
                    title: "Offer Expiry",
                    dropdownValue: selectedExpiry,
                    hintText: "Select expiry",
                    items: const ["7 Days", "14 Days", "30 Days", "60 Days"],
                    onChanged: (value) {
                      if (mounted) setState(() => selectedExpiry = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Please select offer expiry";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextFieldContainer(
                    title: "Offer Details",
                    child: Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: offerControllers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return OfferDetailTextField(
                              controller: offerControllers[index],
                              clearOnTap: offerControllers.length > 1
                                  ? () {
                                      setState(() {
                                        offerControllers[index].dispose();
                                        offerControllers.removeAt(index);
                                      });
                                    }
                                  : null,
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        OfferDottedAddButton(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                offerControllers.add(TextEditingController());
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextFieldContainer(
                    title: "Terms & Condition",
                    child: Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: termsControllers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return OfferDetailTextField(
                              controller: termsControllers[index],
                              clearOnTap: termsControllers.length > 1
                                  ? () {
                                      setState(() {
                                        termsControllers[index].dispose();
                                        termsControllers.removeAt(index);
                                      });
                                    }
                                  : null,
                            );
                          },
                        ),

                        const SizedBox(height: 10),
                        SizedBox(height: 10),
                        OfferDottedAddButton(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                termsControllers.add(TextEditingController());
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomFullButton(
                    title: widget.offerData != null
                        ? "Update Offer"
                        : "Create Offer",
                    isDialogue: true,
                    onTap: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      if (selectedShopNotifier.value == null) {
                        CustomToast.show(
                          context,
                          title: "Please select a shop.",
                          isError: true,
                        );
                        return;
                      }
                      if (selectedPercentage == null) {
                        CustomToast.show(
                          context,
                          title: "Please select an offer percentage.",
                          isError: true,
                        );
                        return;
                      }
                      final validDetails = offerControllers
                          .map((e) => e.text)
                          .where((t) => t.trim().isNotEmpty)
                          .toList();
                      if (validDetails.isEmpty) {
                        CustomToast.show(
                          context,
                          title: "Please add at least one offer detail.",
                          isError: true,
                        );
                        return;
                      }
                      final validTerms = termsControllers
                          .map((e) => e.text)
                          .where((t) => t.trim().isNotEmpty)
                          .toList();
                      if (validTerms.isEmpty) {
                        CustomToast.show(
                          context,
                          title: "Please add at least one term and condition.",
                          isError: true,
                        );
                        return;
                      }

                      setState(() {
                        isSuccess = true;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ShopDetailCard extends StatelessWidget {
  final ShopDetailData shopData;

  const ShopDetailCard({super.key, required this.shopData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteText,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.hardEdge,
          child: CustomNetworkImage(imageUrl: shopData.shopImage ?? ""),
        ),
        title: HeaderTextPrimary(
          title: shopData.shopName ?? "",
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitle: BodyTextHint(
          title: shopData.category ?? "",
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
        trailing: Image.asset(AppIcons.padLockP, height: 30),
      ),
    );
  }
}

class OfferDetailTextField extends StatelessWidget {
  const OfferDetailTextField({
    super.key,
    required this.controller,
    required this.clearOnTap,
  });

  final TextEditingController controller;
  final Function()? clearOnTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(AppIcons.offerStar),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: AppTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ).textStyle,
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: GenericColors.borderGrey,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: GenericColors.borderGrey,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: clearOnTap,
          icon: Icon(
            Icons.cancel_outlined,
            size: 20,
            color: clearOnTap == null
                ? GenericColors.darkRed.withValues(alpha: .1)
                : GenericColors.darkRed,
          ),
        ),
      ],
    );
  }
}

class OfferDottedAddButton extends StatelessWidget {
  const OfferDottedAddButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          borderRadius: 5,
          borderColor: AppColors.primary,
        ),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              BodyTextColors(
                title: 'Add custom',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientTicketWidget extends StatelessWidget {
  final String title;
  final String percentage;
  final String shopName;
  final List<String> offerDetails;
  final List<String> termsAndConditions;

  const GradientTicketWidget({
    super.key,
    required this.title,
    required this.percentage,
    required this.shopName,
    required this.offerDetails,
    required this.termsAndConditions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const VerticalTicketBorderPainter(),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30),

              HeaderTextBlack(
                title: title,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),

              const SizedBox(height: 20),

              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0XFFCB30E0), Color(0XFF6F1A7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: BodyTextColors(
                  title: percentage.contains("OFF")
                      ? percentage
                      : "$percentage OFF",
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteText,
                ),
              ),

              const SizedBox(height: 10),

              BodyTextHint(
                title: shopName,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),

              const SizedBox(height: 40),

              const DashedDivider(),

              const SizedBox(height: 20),

              if (offerDetails.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: HeaderTextBlack(
                      title: "Offer Details",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: offerDetails.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return BodyTextHint(
                      title: offerDetails[index].isNotEmpty
                          ? "👗 ${offerDetails[index]}"
                          : "",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    );
                  },
                ),
                const DashedDivider(),
                const SizedBox(height: 20),
              ],

              if (termsAndConditions.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: HeaderTextBlack(
                      title: "Terms & Conditions",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: termsAndConditions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return BodyTextHint(
                      title: termsAndConditions[index].isNotEmpty
                          ? "🎊 ${termsAndConditions[index]}"
                          : "",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class VerticalTicketBorderPainter extends CustomPainter {
  final double borderWidth;
  final double dashLength;
  final double dashGap;
  final double cornerRadius;
  final double cutoutRadius;

  const VerticalTicketBorderPainter({
    this.borderWidth = 1.5,
    this.dashLength = 4,
    this.dashGap = 5,
    this.cornerRadius = 20,
    this.cutoutRadius = 25,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _ticketPath(size);

    /// White Background
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    /// Gradient Dashed Border
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [GenericColors.darkGreen, GenericColors.darkYellow],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final dash = metric.extractPath(distance, distance + dashLength);

        canvas.drawPath(dash, borderPaint);

        distance += dashLength + dashGap;
      }
    }
  }

  Path _ticketPath(Size size) {
    final path = Path();

    path.moveTo(cornerRadius, 0);

    // ---------------- TOP ----------------
    path.lineTo(size.width / 2 - cutoutRadius, 0);

    path.arcToPoint(
      Offset(size.width / 2 + cutoutRadius, 0),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(size.width - cornerRadius, 0);

    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
    );

    // ---------------- RIGHT ----------------
    path.lineTo(size.width, size.height - cornerRadius);

    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
    );

    // ---------------- BOTTOM ----------------
    path.lineTo(size.width / 2 + cutoutRadius, size.height);

    path.arcToPoint(
      Offset(size.width / 2 - cutoutRadius, size.height),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(cornerRadius, size.height);

    path.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
    );

    // ---------------- LEFT ----------------
    path.lineTo(0, cornerRadius);

    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
    );

    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant VerticalTicketBorderPainter oldDelegate) {
    return oldDelegate.borderWidth != borderWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.cutoutRadius != cutoutRadius;
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final double dashWidth;
  final double dashSpace;
  final Color color;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.color = GenericColors.borderGrey,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _DashedLinePainter(
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        color: color,
        strokeWidth: height,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final double strokeWidth;

  _DashedLinePainter({
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
