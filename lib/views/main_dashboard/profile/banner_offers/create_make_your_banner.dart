import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:mapman/controller/offer_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:mapman/controller/profile_controller.dart';
import 'package:mapman/views/widgets/custom_dialogues.dart';
import 'package:mapman/model/offers_model.dart';
import 'package:mapman/model/shop_detail_model.dart';

class CreateMakeYourBanner extends StatefulWidget {
  final BannerData? banner;

  const CreateMakeYourBanner({super.key, this.banner});

  @override
  State<CreateMakeYourBanner> createState() => _CreateMakeYourBannerState();
}

class _CreateMakeYourBannerState extends State<CreateMakeYourBanner> {
  late TextEditingController titleController,
      descriptionController,
      ctaController;
  final formKey = GlobalKey<FormState>();
  List<Color> bannerColors = [AppColors.whiteText, AppColors.whiteText];
  String illustration = "";
  final ValueNotifier<ShopDetailData?> selectedShopNotifier = ValueNotifier(null);
  final ValueNotifier<List<DateTime>> selectedDatesNotifier = ValueNotifier([]);
  final ValueNotifier<DateTime?> focusedDateNotifier = ValueNotifier(null);

  Color _parseColor(String colorString) {
    try {
      colorString = colorString.toUpperCase().replaceAll(
        RegExp(r'[^A-F0-9]'),
        "",
      );
      if (colorString.length == 6) {
        colorString = "FF$colorString";
      }
      if (colorString.isEmpty) return Colors.white;
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return Colors.white;
    }
  }

  @override
  void initState() {
    titleController = TextEditingController(
      text: widget.banner?.headerText ?? "",
    );
    descriptionController = TextEditingController(
      text: widget.banner?.description ?? "",
    );
    ctaController = TextEditingController(text: widget.banner?.cta ?? "");

    if (widget.banner != null) {
      illustration = widget.banner?.image ?? "";
      final cStr = widget.banner?.color ?? "";
      if (cStr.trim().startsWith('[')) {
        try {
          final List<dynamic> jList = jsonDecode(cStr);
          bannerColors = jList.map((e) => _parseColor(e.toString())).toList();
        } catch (e) {}
      } else if (cStr.contains(',')) {
        bannerColors = cStr
            .split(',')
            .map((e) => _parseColor(e.trim()))
            .toList();
      } else if (cStr.isNotEmpty) {
        final parsed = _parseColor(cStr);
        bannerColors = [parsed, parsed];
      }
      if (bannerColors.length == 1) {
        bannerColors.add(bannerColors.first);
      }
    }

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileController = context.read<ProfileController>();
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
    titleController.dispose();
    descriptionController.dispose();
    ctaController.dispose();
    selectedShopNotifier.dispose();
    selectedDatesNotifier.dispose();
    focusedDateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offerController = context.watch<OfferController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: "Make Your Own Banner"),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(15),
            children: [
              CustomBannerCard(
                title: titleController.text,
                description: descriptionController.text,
                cta: ctaController.text,
                colors: bannerColors,
                image: illustration,
                colorsOnTap: () async {
                  final result = await BannerDialogues().showColorsDialogue(
                    context,
                  );
                  if (result != null) {
                    List<Color> colors = result;
                    if (mounted) setState(() => bannerColors = colors);
                  }
                },
                layersOnTap: () async {
                  final result = await BannerDialogues()
                      .showIllustrationDialogue(context);
                  if (result != null) {
                    if (mounted) setState(() => illustration = result);
                  }
                },
              ),
              SizedBox(height: 20),
              ValueListenableBuilder<ShopDetailData?>(
                valueListenable: selectedShopNotifier,
                builder: (context, selectedShop, child) {
                  final profileController = context.watch<ProfileController>();
                  final items = profileController.shopListData.data ?? [];

                  ShopDetailData? validValue;

                  if (selectedShop != null && items.isNotEmpty) {
                    for (final item in items) {
                      if (item.id == selectedShop.id) {
                        validValue = item;
                        break;
                      }
                    }
                  }

                  return CustomTextFieldContainer(
                    title: "Select shop",
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<ShopDetailData>(
                        isExpanded: true,
                        value: validValue,
                        isDense: true,
                        onChanged: (value) {
                          if (value != null) {
                            selectedShopNotifier.value = value;
                          }
                        },
                        hint: BodyTextColors(
                          title: "Select shop",
                          overflow: TextOverflow.ellipsis,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.hintColor,
                        ),
                        items: items.map((item) {
                          return DropdownMenuItem<ShopDetailData>(
                            value: item,
                            child: BodyTextColors(
                              title: item.shopName ?? '',
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText,
                            ),
                          );
                        }).toList(),
                        buttonStyleData: const ButtonStyleData(
                          height: 45,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down_rounded),
                          iconSize: 24,
                          iconEnabledColor: AppColors.darkText,
                          iconDisabledColor: AppColors.darkText,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          padding: EdgeInsets.zero,
                          offset: const Offset(0, -5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 45,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              CustomTextField(
                title: "Header Text",
                controller: titleController,
                hintText: "eg.Summer sale is Live!!",
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter header text";
                  }
                  return null;
                },
                onFieldChanged: (value) {
                  if (mounted) setState(() => titleController.text = value);
                },
              ),
              SizedBox(height: 20),
              CustomTextField(
                title: "Description",
                controller: descriptionController,
                hintText: "eg.Flat 30% off on all products ",
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter description";
                  }
                  return null;
                },
                onFieldChanged: (value) {
                  if (mounted) {
                    setState(() => descriptionController.text = value);
                  }
                },
              ),
              SizedBox(height: 20),
              CustomTextField(
                title: "CTA (call to Action)",
                controller: ctaController,
                hintText: "eg.Shop Now",
                inputAction: TextInputAction.done,
                onFieldChanged: (value) {
                  if (mounted) setState(() => ctaController.text = value);
                },
              ),
              SizedBox(height: 40),

              ValueListenableBuilder<List<DateTime>>(
                valueListenable: selectedDatesNotifier,
                builder: (context, selectedDates, _) {
                  final monthlyData = offerController.monthlyBannersData.data ?? [];
                  return _CustomCalendarWidget(
                    fullDates: monthlyData,
                    selectedDates: selectedDates,
                    onMonthChanged: (monthStr) {
                      offerController.fetchMonthlyBanners(month: monthStr);
                    },
                    onDateTapped: (date) {
                      final dateStr = DateFormat('yyyy-MM-dd').format(date);
                      if (monthlyData.contains(dateStr)) return;
                      
                      List<DateTime> newDates = List.from(selectedDates);
                      bool exists = false;
                      for (var d in newDates) {
                        if (DateFormat('yyyy-MM-dd').format(d) == dateStr) {
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const BodyTextHint(title: 'Selected Date', fontSize: 14),
                            HeaderTextBlack(
                              title: focusedDate != null ? DateFormat('MMM dd, yyyy').format(focusedDate) : 'Today',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BodyTextHint(title: 'Slots free', fontSize: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                BodyTextColors(
                                  title: '$freeSlots of $totalSlots',
                                  fontSize: 14,
                                  color: freeSlots > 0 ? GenericColors.darkGreen : GenericColors.darkRed,
                                ),
                                const SizedBox(height: 5),
                                BodyTextColors(
                                  title: 'out of 6 home page banner slots',
                                  fontSize: 12,
                                  color: AppColors.darkGrey.withValues(alpha: .5),
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

              CustomFullButton(
                title: "Proceed to Payment",
                isDialogue: true,
                onTap: () async {
                  if (formKey.currentState!.validate()) {
                    final shopId = selectedShopNotifier.value?.id ?? 0;
                    if (shopId == 0) {
                      CustomToast.show(context, title: "Please select a shop");
                      return;
                    }

                    String colorStr = "";
                    if (bannerColors.isNotEmpty) {
                      final hex1 =
                          "#${bannerColors[0].value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}";
                      final hex2 = bannerColors.length > 1
                          ? "#${bannerColors[1].value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}"
                          : hex1;
                      colorStr = "[\"$hex1\", \"$hex2\"]";
                    }

                    List<String> alreadyScheduled = [];
                    final dayBanners = context.read<OfferController>().dayBannersData.data?.data?.banners;
                    if (dayBanners != null) {
                      for (var b in dayBanners) {
                        if (b.bannerSchedule != null) {
                          alreadyScheduled.addAll(b.bannerSchedule!);
                        }
                      }
                    }
                    List<String> finalDatesToSend = [];
                    for (var d in selectedDatesNotifier.value) {
                      String dStr = DateFormat('yyyy-MM-dd').format(d);
                      if (!alreadyScheduled.contains(dStr)) {
                        finalDatesToSend.add(dStr);
                      }
                    }

                    final body = <String, dynamic>{
                      "shopId": shopId,
                      "bannerType": "text",
                      "type": widget.banner != null ? "update" : "add",
                      "illustration": illustration,
                      "headerText": titleController.text,
                      "description": descriptionController.text,
                      "cta": ctaController.text,
                      "color": colorStr,
                      "bannerId": widget.banner?.id ?? 0,
                    };
                    if (finalDatesToSend.isNotEmpty) {
                      body["bannerSchedule"] = finalDatesToSend;
                    }

                    CustomDialogues.showLoadingDialogue(context);
                    final response = await Provider.of<OfferController>(
                      context,
                      listen: false,
                    ).manageBannerText(body: body);
                    if (!context.mounted) return;
                    Navigator.pop(context);

                    if (response.status == Status.COMPLETED) {
                      Provider.of<OfferController>(
                        context,
                        listen: false,
                      ).getShopBanners(shopId: shopId);
                      CustomToast.show(
                        context,
                        title: widget.banner != null
                            ? "Banner updated successfully"
                            : "Banner created successfully",
                      );
                      Navigator.pop(context);
                    } else {
                      CustomToast.show(
                        context,
                        title: "${response.message}",
                        isError: true,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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
              bool isSelected = widget.selectedDates.any((d) => DateFormat('yyyy-MM-dd').format(d) == cellDateStr);

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

class CustomBannerCard extends StatelessWidget {
  const CustomBannerCard({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.cta,
    required this.colors,
    required this.colorsOnTap,
    required this.layersOnTap,
  });

  final String title, description, cta, image;
  final List<Color> colors;
  final VoidCallback colorsOnTap, layersOnTap;

  @override
  Widget build(BuildContext context) {
    final headerTitle = title.isNotEmpty ? title : "Your Header text here";
    final descriptionTitle = description.isNotEmpty
        ? description
        : "Your description goes here";
    final ctaTitle = cta.isNotEmpty ? cta : "CTA (shop now)";
    return Container(
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: colors),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: HeaderTextPrimary(
              title: headerTitle,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            subtitle: BodyTextHint(
              title: descriptionTitle,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: colorsOnTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.scaffoldBackgroundDark,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Image.asset(AppIcons.colorsP, height: 20, width: 20),
                  ),
                ),

                SizedBox(width: 10),
                GestureDetector(
                  onTap: layersOnTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.scaffoldBackgroundDark,
                    ),
                    padding: EdgeInsets.all(10),
                    child: (image.startsWith('http'))
                        ? CachedNetworkImage(
                            imageUrl: image,
                            height: 20,
                            width: 20,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, size: 20),
                          )
                        : Image.asset(
                            image.isNotEmpty ? image : AppIcons.layerP,
                            height: 20,
                            width: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            margin: EdgeInsets.only(left: 15, bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: BodyTextColors(
              title: ctaTitle,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.whiteText,
            ),
          ),
        ],
      ),
    );
  }
}

class BannerDialogues {
  Future<List<Color>?> showColorsDialogue(BuildContext context) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(content: _BannerColorsContainer());
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: AppColors.whiteText,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: _BannerColorsContainer(),
          );
        },
      );
    }
  }

  Future<String?> showIllustrationDialogue(BuildContext context) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(content: _BannerIllustrationContainer());
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: AppColors.whiteText,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: _BannerIllustrationContainer(),
          );
        },
      );
    }
  }
}

class _BannerColorsContainer extends StatefulWidget {
  const _BannerColorsContainer();

  @override
  State<_BannerColorsContainer> createState() => _BannerColorsContainerState();
}

class _BannerColorsContainerState extends State<_BannerColorsContainer> {
  final List<List<Color>> bannerColors = [
    [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
    [const Color(0xFF00D715), const Color(0xFFF8BD00)],
    [const Color(0xFFCB30E0), const Color(0xFF6F1A7A)],
    [const Color(0xFF0F56D1), const Color(0xFF000000)],
    [const Color(0xFFFF2D55), const Color(0xFF572D35)],
    [const Color(0xFF1ED7FE), const Color(0xFF48B2FE)],
    [const Color(0xFFFF8D28), const Color(0xFFFF8D28)],
    [const Color(0xFFFF383C), const Color(0xFFFF383C)],
    [const Color(0xFFFFCC00), const Color(0xFFFFCC00)],
    [const Color(0xFF34C759), const Color(0xFF34C759)],
    [const Color(0xFF0088FF), const Color(0xFF0088FF)],
    [const Color(0xFFAC7F5E), const Color(0xFFAC7F5E)],
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OfferController>(context, listen: false).fetchColors();
    });
  }

  Color _parseColor(String colorString) {
    try {
      colorString = colorString.toUpperCase().replaceAll(
        RegExp(r'[^A-F0-9]'),
        "",
      );
      if (colorString.length == 6) {
        colorString = "FF$colorString";
      }
      if (colorString.isEmpty) return Colors.white;
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OfferController>(
      builder: (context, controller, child) {
        final isLoading = controller.colorsData.status == Status.LOADING;
        final colorList = controller.colorsData.data ?? [];

        List<List<Color>> displayColors = [];
        if (!isLoading && colorList.isNotEmpty) {
          for (var cData in colorList) {
            if (cData.color != null) {
              final c = cData.color!;
              List<Color> gradientColors = [];

              if (c.trim().startsWith('[')) {
                try {
                  final List<dynamic> jsonList = jsonDecode(c);
                  gradientColors = jsonList
                      .map((e) => _parseColor(e.toString()))
                      .toList();
                } catch (e) {
                  gradientColors = [Colors.white, Colors.white];
                }
              } else if (c.contains(',')) {
                gradientColors = c
                    .split(',')
                    .map((e) => _parseColor(e.trim()))
                    .toList();
              } else {
                final parsed = _parseColor(c);
                gradientColors = [parsed, parsed];
              }

              if (gradientColors.isNotEmpty) {
                if (gradientColors.length == 1) {
                  gradientColors.add(gradientColors.first);
                }
                displayColors.add(gradientColors);
              }
            }
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isAndroid) SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.scaffoldBackgroundDark,
                  ),
                  child: Image.asset(AppIcons.colorsP, height: 20, width: 20),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderTextBlack(
                        title: "Banner Color",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      BodyTextHint(
                        title: "Choose your preferred banner color",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const CustomDivider(padding: EdgeInsets.symmetric(vertical: 20)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: isLoading ? 1 : displayColors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 40,
                ),
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return const CustomLoadingIndicator();
                  }
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      if (mounted) setState(() => selectedIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: displayColors[index]),
                      ),
                      child: isSelected
                          ? SvgPicture.asset(
                              AppIcons.doubleCheck,
                              height: 20,
                              width: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomOutlineButton(
                      title: "Cancel",
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomFullButton(
                      title: "Apply",
                      isDialogue: true,
                      onTap: () {
                        if (isLoading || displayColors.isEmpty) return;
                        Navigator.pop(context, displayColors[selectedIndex]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (Platform.isAndroid) SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _BannerIllustrationContainer extends StatefulWidget {
  const _BannerIllustrationContainer();

  @override
  State<_BannerIllustrationContainer> createState() =>
      _BannerIllustrationContainerState();
}

class _BannerIllustrationContainerState
    extends State<_BannerIllustrationContainer> {
  final List<String> illustrations = [
    AppIcons.galleryP,
    AppIcons.galleryP,
    AppIcons.galleryP,
    AppIcons.galleryP,
    AppIcons.galleryP,
    AppIcons.galleryP,
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OfferController>(context, listen: false).fetchIllustrations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OfferController>(
      builder: (context, controller, child) {
        final isLoading = controller.illustrationsData.status == Status.LOADING;
        final illList = controller.illustrationsData.data ?? [];

        List<String> displayIllus = [];
        if (!isLoading && illList.isNotEmpty) {
          for (var iData in illList) {
            if (iData.illustration != null) {
              displayIllus.add(iData.illustration!);
            }
          }
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (Platform.isAndroid) const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.scaffoldBackgroundDark,
                        ),
                        child: Image.asset(
                          AppIcons.layerP,
                          height: 20,
                          width: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeaderTextBlack(
                              title: "Illustration",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 4),
                            BodyTextHint(
                              title: "Choose your illustration",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const CustomDivider(
                  padding: EdgeInsets.symmetric(vertical: 20),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: isLoading ? 1 : displayIllus.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Platform.isIOS ? 3 : 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 72,
                    ),
                    itemBuilder: (context, index) {
                      if (isLoading) {
                        return const CustomLoadingIndicator();
                      }
                      final isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          if (mounted) setState(() => selectedIndex = index);
                        },
                        child: AnimatedScale(
                          scale: 1,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        GenericColors.darkGreen,
                                        GenericColors.darkYellow,
                                      ],
                                    )
                                  : null,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.whiteText
                                    : AppColors.scaffoldBackgroundDark,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (displayIllus[index].startsWith('http'))
                                      ? CachedNetworkImage(
                                          imageUrl: displayIllus[index],
                                          height: 25,
                                          width: 25,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error, size: 25),
                                        )
                                      : Image.asset(
                                          displayIllus[index],
                                          height: 25,
                                          width: 25,
                                        ),
                                  const SizedBox(height: 5),
                                  const BodyTextHint(
                                    title: "None",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomOutlineButton(
                          title: "Cancel",
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomFullButton(
                          title: "Apply",
                          isDialogue: true,
                          onTap: () {
                            if (isLoading || displayIllus.isEmpty) return;
                            Navigator.of(
                              context,
                            ).pop(displayIllus[selectedIndex]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (Platform.isAndroid) const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
