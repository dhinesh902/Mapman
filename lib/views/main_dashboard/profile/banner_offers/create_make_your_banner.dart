import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mapman/routes/app_routes.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/enums.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';
import 'package:mapman/views/widgets/custom_snackbar.dart';
import 'package:mapman/views/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:mapman/controller/offer_controller.dart';
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
  late OfferController offerController;
  late TextEditingController titleController,
      descriptionController,
      ctaController;
  final formKey = GlobalKey<FormState>();

  String backgroundImage = "";
  String selectedFont = "Roboto";
  final ValueNotifier<ShopDetailData?> selectedShopNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<List<DateTime>> selectedDatesNotifier = ValueNotifier([]);
  final ValueNotifier<DateTime?> focusedDateNotifier = ValueNotifier(null);

  Color _fontColor = AppColors.primary;
  Color _backgroundColor = AppColors.primary;

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    final colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.brown,
      Colors.grey,
      Colors.indigo,
      Colors.lime,
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            children: [
              const Text(
                "Select Color",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        onColorSelected(colors[index]);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorSelector({
    required String title,
    required Color selectedColor,
    required Function(Color) onColorSelected,
  }) {
    return GestureDetector(
      onTap: () => _showColorPicker(context, selectedColor, onColorSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    offerController = context.read<OfferController>();
    selectedFont = widget.banner?.font ?? 'Roboto';
    titleController = TextEditingController(
      text: widget.banner?.headerText ?? "",
    );
    descriptionController = TextEditingController(
      text: widget.banner?.description ?? "",
    );
    ctaController = TextEditingController(text: widget.banner?.cta ?? "");

    if (widget.banner != null) {
      backgroundImage = widget.banner?.backgroundImage ?? "";
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
    offerController = context.watch<OfferController>();
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: "Make Your Own Banner"),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(15),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pink, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      String? result = await context.pushNamed(
                        AppRoutes.selectBanner,
                      );
                      if (result != null) {
                        setState(() => backgroundImage = result);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    splashColor: Colors.white.withValues(alpha: 0.08),
                    highlightColor: Colors.white.withValues(alpha: 0.04),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.whiteText.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const BodyTextColors(
                            title: 'Select Banner',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withValues(alpha: 0.55),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              CustomBannerCard(
                title: titleController.text,
                description: descriptionController.text,
                cta: ctaController.text,
                backgroundImage: backgroundImage,
                selectedFont: selectedFont,
                fontColor: _fontColor,
                backgroundColor: _backgroundColor,
              ),
              SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildColorSelector(
                    title: "Font Color",
                    selectedColor: _fontColor,
                    onColorSelected: (c) => setState(() => _fontColor = c),
                  ),
                  _buildColorSelector(
                    title: "Background Color",
                    selectedColor: _backgroundColor,
                    onColorSelected: (c) =>
                        setState(() => _backgroundColor = c),
                  ),
                ],
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
                maxLength: 30,
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
              const SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) {
                        final fonts = [
                          "Roboto",
                          "Open Sans",
                          "Lato",
                          "Oswald",
                          "Raleway",
                          "Montserrat",
                          "Poppins",
                          "Ubuntu",
                          "Playfair Display",
                          "Merriweather",
                        ];
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.55,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                width: 45,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const HeaderTextBlack(
                                title: "Select Font Style",
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  itemCount: fonts.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final font = fonts[index];
                                    final isSelected = selectedFont == font;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() => selectedFont = font);
                                        Navigator.pop(context);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.08,
                                                )
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.grey.withValues(
                                                    alpha: 0.2,
                                                  ),
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.primary
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              font,
                                              style: GoogleFonts.getFont(
                                                font,
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.darkText,
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                color: AppColors.primary,
                                                size: 22,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.whiteText,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.text_format_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Header Font",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.hintColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedFont,
                                  style: GoogleFonts.getFont(
                                    selectedFont,
                                    fontSize: 15,
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.darkText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                title: "Description",
                maxLength: 50,
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
                  final monthlyData =
                      offerController.monthlyBannersData.data ?? [];
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  child: HeaderTextBlack(
                                    title: dateText,
                                    textAlign: TextAlign.right,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BodyTextHint(
                              title: 'Slots free',
                              fontSize: 14,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                                  title: 'out of 6 home page banner slots',
                                  fontSize: 12,
                                  color: AppColors.darkGrey.withValues(
                                    alpha: .5,
                                  ),
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

                    List<String> finalDatesToSend = [];
                    for (var d in selectedDatesNotifier.value) {
                      String dStr = DateFormat('yyyy-MM-dd').format(d);
                      finalDatesToSend.add(dStr);
                    }

                    final body = <String, dynamic>{
                      "shopId": shopId,
                      "bannerType": "text",
                      "type": widget.banner != null ? "update" : "add",
                      "backgroundImage": backgroundImage,
                      "headerText": titleController.text,
                      "description": descriptionController.text,
                      "cta": ctaController.text,
                      "bannerId": widget.banner?.id ?? 0,
                      "bannerSchedule": finalDatesToSend,
                      "font": selectedFont,
                      "fontColor":
                          '#${(_fontColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
                      "backgroundColor":
                          '#${(_backgroundColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
                    };
                    CustomDialogues.showLoadingDialogue(context);
                    final response = await offerController.manageBannerText(
                      body: body,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);

                    if (response.status == Status.COMPLETED) {
                      offerController.getShopBanners(shopId: shopId);
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

class CustomBannerCard extends StatelessWidget {
  const CustomBannerCard({
    super.key,
    required this.title,
    required this.description,
    required this.cta,
    required this.backgroundImage,
    required this.selectedFont,
    this.fontColor = Colors.white,
    this.backgroundColor = Colors.white,
  });

  final String title, description, cta, backgroundImage, selectedFont;
  final Color fontColor, backgroundColor;

  @override
  Widget build(BuildContext context) {
    final headerTitle = title.isNotEmpty ? title : "Your Header text here";
    final descriptionTitle = description.isNotEmpty
        ? description
        : "Your description goes here";
    final ctaTitle = cta.isNotEmpty ? cta : "CTA (shop now)";
    return Container(
      height: 155,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.whiteText,
        borderRadius: BorderRadius.circular(10),
        image: backgroundImage.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(backgroundImage),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headerTitle,
            style: GoogleFonts.getFont(
              selectedFont,
              fontSize: 16,
              color: fontColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          BodyTextColors(
            title: descriptionTitle,
            fontSize: 12,
            color: fontColor,
            fontWeight: FontWeight.w300,
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
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
