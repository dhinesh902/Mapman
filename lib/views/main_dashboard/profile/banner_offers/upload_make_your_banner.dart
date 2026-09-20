import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_image.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:mapman/controller/offer_controller.dart';
import 'package:mapman/model/offers_model.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/model/shop_detail_model.dart';
import 'package:mapman/routes/api_routes.dart';

class UploadMakeYourBanner extends StatefulWidget {
  final BannerData? banner;

  const UploadMakeYourBanner({super.key, this.banner});

  @override
  State<UploadMakeYourBanner> createState() => _UploadMakeYourBannerState();
}

class _UploadMakeYourBannerState extends State<UploadMakeYourBanner> {
  final ValueNotifier<File?> profileImageNotifier = ValueNotifier(null);
  final ValueNotifier<bool> proceedToPaymentNotifier = ValueNotifier(false);
  final ValueNotifier<ShopDetailData?> selectedShopNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<List<DateTime>> selectedDatesNotifier = ValueNotifier([]);
  final ValueNotifier<DateTime?> focusedDateNotifier = ValueNotifier(null);
  late OfferController offerController;
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    offerController = context.read<OfferController>();
    profileController = context.read<ProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final res = await profileController.getShopList();
      if (res.status == Status.COMPLETED &&
          res.data != null &&
          res.data!.isNotEmpty) {
        if (widget.banner != null) {
          try {
            selectedShopNotifier.value = res.data!.firstWhere(
              (s) => s.id == widget.banner!.shopId,
            );
          } catch (_) {
            selectedShopNotifier.value = res.data!.first;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    profileImageNotifier.dispose();
    proceedToPaymentNotifier.dispose();
    selectedShopNotifier.dispose();
    selectedDatesNotifier.dispose();
    focusedDateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    offerController = context.watch<OfferController>();
    profileController = context.watch<ProfileController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: "Make Your Own Banner"),
        body: ValueListenableBuilder(
          valueListenable: proceedToPaymentNotifier,
          builder: (context, proceed, _) {
            return ValueListenableBuilder(
              valueListenable: profileImageNotifier,
              builder: (context, image, _) {
                return ValueListenableBuilder<ShopDetailData?>(
                  valueListenable: selectedShopNotifier,
                  builder: (context, selectedShop, _) {
                    return ListView(
                      padding: const EdgeInsets.all(15),
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            CustomImagePicker.showImagePicker(
                              context,
                              cameraOnTap: () {
                                _pickImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                              galleryOnTap: () {
                                _pickImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            );
                          },
                          child: GradientDashedBorderContainer(
                            borderRadius: 10,
                            strokeWidth: 2,
                            dashLength: 8,
                            dashGap: 4,
                            gradient: const LinearGradient(
                              colors: [
                                GenericColors.darkGreen,
                                GenericColors.darkYellow,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            child: Container(
                              height: 210,
                              padding: const EdgeInsets.all(1),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(image.path),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : (widget.banner?.image != null &&
                                        widget.banner!.image
                                            .toString()
                                            .isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CustomNetworkImage(
                                        imageUrl:
                                            widget.banner!.image
                                                .toString()
                                                .startsWith('https')
                                            ? widget.banner!.image.toString()
                                            : '${ApiRoutes.baseUrl}${widget.banner!.image}',
                                        boxFit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppIcons.galleryP,
                                          height: 52,
                                          width: 52,
                                        ),
                                        const SizedBox(height: 10),
                                        HeaderTextPrimary(
                                          title: "Tap to Upload an Image",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        const SizedBox(height: 10),
                                        BodyTextHint(
                                          title:
                                              "Only 1080 × 1080 images are allowed",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (!proceed &&
                            (image != null || widget.banner?.image != null))
                          GestureDetector(
                            onTap: () => profileImageNotifier.value = null,
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBackgroundDark,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: AppColors.lightGreyHint,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AppIcons.exchange,
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  HeaderTextBlack(
                                    title: "Change Image",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (!proceed && image != null)
                          const SizedBox(height: 20),

                        if (!proceed)
                          Builder(
                            builder: (context) {
                              final items =
                                  profileController.shopListData.data ?? [];

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

                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.scaffoldBackgroundDark,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: AppColors.lightGreyHint,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<ShopDetailData>(
                                    isExpanded: true,
                                    hint: HeaderTextBlack(
                                      title:
                                          profileController
                                                  .shopListData
                                                  .status ==
                                              Status.LOADING
                                          ? "Loading shops..."
                                          : "Select Shop",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    dropdownColor:
                                        AppColors.scaffoldBackgroundDark,
                                    value: validValue,
                                    items: items.map((shop) {
                                      return DropdownMenuItem(
                                        value: shop,
                                        child: HeaderTextBlack(
                                          title:
                                              shop.shopName ?? "Unknown Shop",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      selectedShopNotifier.value = value;
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                        ValueListenableBuilder<List<DateTime>>(
                          valueListenable: selectedDatesNotifier,
                          builder: (context, selectedDates, _) {
                            final monthlyData =
                                offerController.monthlyBannersData.data ?? [];
                            return _CustomCalendarWidget(
                              fullDates: monthlyData,
                              selectedDates: selectedDates,
                              onMonthChanged: (monthStr) {
                                offerController.fetchMonthlyBanners(
                                  month: monthStr,
                                );
                              },
                              onDateTapped: (date) {
                                final dateStr = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(date);
                                if (monthlyData.contains(dateStr)) return;

                                List<DateTime> newDates = List.from(
                                  selectedDates,
                                );
                                bool exists = false;
                                for (var d in newDates) {
                                  if (DateFormat('yyyy-MM-dd').format(d) ==
                                      dateStr) {
                                    exists = true;
                                    newDates.remove(d);
                                    break;
                                  }
                                }
                                if (!exists) {
                                  newDates.add(date);
                                }
                                selectedDatesNotifier.value = newDates;
                                focusedDateNotifier.value = date;
                                offerController.fetchDayBanners(date: dateStr);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<DateTime?>(
                          valueListenable: focusedDateNotifier,
                          builder: (context, focusedDate, _) {
                            final dayData = offerController.dayBannersData.data;
                            int bookedSlots = dayData?.data?.count ?? 0;
                            int totalSlots = 6;
                            int freeSlots = totalSlots - bookedSlots;

                            return Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: AppColors.whiteText,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const BodyTextHint(
                                        title: 'Selected Date',
                                        fontSize: 14,
                                      ),
                                      const SizedBox(width: 15),
                                      ValueListenableBuilder<List<DateTime>>(
                                        valueListenable: selectedDatesNotifier,
                                        builder: (context, selectedDates, _) {
                                          String dateText = 'Today';
                                          if (selectedDates.isNotEmpty) {
                                            var sorted = List<DateTime>.from(
                                              selectedDates,
                                            )..sort();
                                            dateText = sorted
                                                .map(
                                                  (d) => DateFormat(
                                                    'MMM dd, yyyy',
                                                  ).format(d),
                                                )
                                                .join('\n');
                                          } else if (focusedDate != null) {
                                            dateText = DateFormat(
                                              'MMM dd, yyyy',
                                            ).format(focusedDate);
                                          }
                                          return Expanded(
                                            child: Text(
                                              dateText,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const BodyTextHint(
                                        title: 'Slots free',
                                        fontSize: 14,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          BodyTextColors(
                                            title: '$freeSlots of $totalSlots',
                                            fontSize: 14,
                                            color: freeSlots > 0
                                                ? GenericColors.darkGreen
                                                : GenericColors.darkRed,
                                          ),
                                          const SizedBox(height: 5),
                                          BodyTextColors(
                                            title:
                                                'out of 6 home page banner slots',
                                            fontSize: 12,
                                            color: AppColors.darkGrey
                                                .withValues(alpha: .5),
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        if (proceed) ...[
                          CustomRowWidget(
                            headerChild: HeaderTextBlack(
                              title: "Banner Type",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            valueChild: BodyTextColors(
                              title: "Uploaded Image",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: GenericColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 20),

                          const CustomDivider(),
                          const SizedBox(height: 20),

                          CustomRowWidget(
                            headerChild: BodyTextColors(
                              title: "Banner Charge",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText.withValues(alpha: .7),
                            ),
                            valueChild: BodyTextColors(
                              title: "Rs.99",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText.withValues(alpha: .7),
                            ),
                          ),

                          const SizedBox(height: 20),

                          CustomRowWidget(
                            headerChild: BodyTextColors(
                              title: "GST (18%)",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText.withValues(alpha: .7),
                            ),
                            valueChild: BodyTextColors(
                              title: "Rs.18",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText.withValues(alpha: .7),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const CustomDivider(),
                          const SizedBox(height: 10),

                          CustomRowWidget(
                            headerChild: HeaderTextBlack(
                              title: "Total",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            valueChild: HeaderTextBlack(
                              title: "Rs.117",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 10),
                          const CustomDivider(),
                          const SizedBox(height: 20),
                        ],
                        const SizedBox(height: 20),

                        offerController.apiResponse.status == Status.LOADING
                            ? ButtonProgressBar()
                            : CustomFullButton(
                                title: proceed
                                    ? "Pay Now"
                                    : "Proceed to Payment",
                                color:
                                    ((image != null || widget.banner != null) &&
                                        selectedShopNotifier.value != null)
                                    ? AppColors.primary
                                    : AppColors.bgGrey,
                                isDialogue: true,
                                onTap:
                                    ((image == null && widget.banner == null) ||
                                        selectedShopNotifier.value == null)
                                    ? () {
                                        if (image == null &&
                                            widget.banner == null) {
                                          CustomToast.show(
                                            context,
                                            title: "Please upload an image",
                                            isError: true,
                                          );
                                        } else if (selectedShopNotifier.value ==
                                            null) {
                                          CustomToast.show(
                                            context,
                                            title: "Please select a shop",
                                            isError: true,
                                          );
                                        }
                                      }
                                    : () async {
                                        if (!proceed) {
                                          proceedToPaymentNotifier.value = true;
                                        } else {
                                          List<String> finalDatesToSend = [];
                                          for (var d
                                              in selectedDatesNotifier.value) {
                                            String dStr = DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(d);
                                            finalDatesToSend.add(dStr);
                                          }
                                          if (finalDatesToSend.isEmpty) {
                                            CustomToast.show(
                                              context,
                                              title: "Please select dates",
                                              isError: true,
                                            );
                                            return;
                                          }
                                          final response = await offerController
                                              .manageBannerImage(
                                                banner: BannerData(
                                                  image: image,
                                                  type: widget.banner != null
                                                      ? "update"
                                                      : "add",
                                                  bannerType: "image",
                                                  shopId: selectedShopNotifier
                                                      .value!
                                                      .id,
                                                  id: widget.banner?.id ?? 0,
                                                  bannerSchedule:
                                                      finalDatesToSend
                                                          .isNotEmpty
                                                      ? finalDatesToSend
                                                      : null,
                                                ),
                                              );

                                          if (!context.mounted) return;

                                          if (response.status ==
                                              Status.COMPLETED) {
                                            offerController.getShopBanners(
                                              shopId:
                                                  selectedShopNotifier
                                                      .value!
                                                      .id ??
                                                  0,
                                            );
                                            CustomToast.show(
                                              context,
                                              title: widget.banner != null
                                                  ? "Banner updated successfully"
                                                  : "Banner created successfully",
                                            );
                                            Navigator.pop(context);
                                            if (widget.banner == null) {
                                              Navigator.pop(context);
                                            }
                                          } else {
                                            CustomToast.show(
                                              context,
                                              title: response.message ?? "",
                                              isError: true,
                                            );
                                          }
                                        }
                                      },
                              ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await CustomImageCropper.cropImage(pickedFile.path);
        if (croppedFile != null) {
          profileImageNotifier.value = File(croppedFile.path);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }
}

class GradientDashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double borderRadius;

  const GradientDashedBorderContainer({
    super.key,
    required this.child,
    required this.gradient,
    this.strokeWidth = 2.0,
    this.dashLength = 5.0,
    this.dashGap = 3.0,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientDashedBorderPainter(
        gradient: gradient,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashGap: dashGap,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class _GradientDashedBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double borderRadius;

  _GradientDashedBorderPainter({
    required this.gradient,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // Create the paint object with gradient shader
    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    // Create the base path (rectangle or rounded rectangle)
    final Path basePath = Path();
    if (borderRadius > 0) {
      basePath.addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      );
    } else {
      basePath.addRect(rect);
    }

    // Convert the solid path into a dashed path
    final Path dashedPath = _createDashedPath(basePath, dashLength, dashGap);

    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashGap) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? dashWidth : dashGap;
        if (draw) {
          dest.addPath(
            metric.extractPath(
              distance,
              math.min(distance + len, metric.length),
            ),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_GradientDashedBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class CustomRowWidget extends StatelessWidget {
  const CustomRowWidget({
    super.key,
    required this.headerChild,
    required this.valueChild,
  });

  final Widget headerChild;
  final Widget valueChild;

  @override
  Widget build(BuildContext context) {
    return Row(children: [headerChild, Spacer(), valueChild]);
  }
}

class _CustomCalendarWidget extends StatefulWidget {
  final List<String> fullDates;
  final List<DateTime> selectedDates;
  final ValueChanged<String> onMonthChanged;
  final ValueChanged<DateTime> onDateTapped;

  const _CustomCalendarWidget({
    required this.fullDates,
    required this.selectedDates,
    required this.onMonthChanged,
    required this.onDateTapped,
  });

  @override
  State<_CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<_CustomCalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMonthChanged(DateFormat('yyyy-MM').format(_currentMonth));
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    widget.onMonthChanged(DateFormat('yyyy-MM').format(_currentMonth));
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    widget.onMonthChanged(DateFormat('yyyy-MM').format(_currentMonth));
  }

  @override
  Widget build(BuildContext context) {
    List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    int daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    int firstDayOfWeek =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    String monthYear = DateFormat('MMMM yyyy').format(_currentMonth);

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _previousMonth,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(width: 30),
              HeaderTextBlack(
                title: monthYear,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(width: 30),
              GestureDetector(
                onTap: _nextMonth,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: BodyTextHint(title: day, fontSize: 14),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstDayOfWeek,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek) {
                return const SizedBox();
              }
              int day = index - firstDayOfWeek + 1;
              String dayStr = day.toString().padLeft(2, '0');
              DateTime cellDate = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                day,
              );
              bool isPast = cellDate.isBefore(today);

              String cellDateStr = DateFormat('yyyy-MM-dd').format(cellDate);
              bool isFull = widget.fullDates.contains(cellDateStr);
              bool isSelected = widget.selectedDates.any(
                (d) => DateFormat('yyyy-MM-dd').format(d) == cellDateStr,
              );

              Color textColor = AppColors.lightGreyHint;
              Color bgColor = AppColors.whiteText;
              Color borderColor = GenericColors.borderGrey.withValues(
                alpha: .5,
              );

              if (!isPast) {
                if (isFull) {
                  textColor = GenericColors.darkRed;
                  bgColor = GenericColors.darkRed.withValues(alpha: .09);
                  borderColor = GenericColors.darkRed.withValues(alpha: .2);
                } else {
                  textColor = GenericColors.darkGreen;
                }
              }

              if (isSelected) {
                bgColor = AppColors.primary;
                textColor = AppColors.whiteText;
              }

              return GestureDetector(
                onTap: isPast || isFull
                    ? null
                    : () {
                        widget.onDateTapped(cellDate);
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: BodyTextColors(
                      title: dayStr,
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: GenericColors.darkGreen,
                ),
              ),
              const SizedBox(width: 8),
              const BodyTextHint(title: "Slots free", fontSize: 14),
              const SizedBox(width: 20),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: GenericColors.darkRed,
                ),
              ),
              const SizedBox(width: 8),
              const BodyTextHint(title: "Full", fontSize: 14),
            ],
          ),
        ],
      ),
    );
  }
}
