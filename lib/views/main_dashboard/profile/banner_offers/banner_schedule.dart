import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/views/widgets/action_bar.dart';
import 'package:mapman/views/widgets/custom_buttons.dart';
import 'package:mapman/views/widgets/custom_containers.dart';
import 'package:mapman/views/widgets/custom_safearea.dart';

class BannerSchedule extends StatefulWidget {
  const BannerSchedule({super.key});

  @override
  State<BannerSchedule> createState() => _BannerScheduleState();
}

class _BannerScheduleState extends State<BannerSchedule> {
  String _selectedDuration = '30 Days';

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        appBar: ActionBar(title: "Schedule your Banner"),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.whiteText,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(3),
                    child: Icon(
                      Icons.priority_high,
                      size: 12,
                      color: AppColors.whiteText,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: BodyTextHint(
                      title:
                          'Home page has 6 banner spots only. Pick a date, book it, your banner goes live on that day.',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: GenericColors.darkRed.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GenericColors.darkRed),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Image.asset(AppIcons.warningP, height: 18),
                  SizedBox(width: 15),
                  Expanded(
                    child: BodyTextColors(
                      title: '6 of 6 slots full today',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: GenericColors.darkRed,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            const _CustomCalendarWidget(),
            const SizedBox(height: 20),
            Container(
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
                      const HeaderTextBlack(
                        title: 'Today',
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
                          const BodyTextColors(
                            title: '0 of 6',
                            fontSize: 14,
                            color: GenericColors.darkRed,
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
            ),
            const SizedBox(height: 20),
            CustomTextFieldContainer(
              title: 'Run Far the Banner',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['7 Days', '10 Days', '14 Days', '30 Days'].map((
                  text,
                ) {
                  bool isSelected = _selectedDuration == text;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDuration = text;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: isSelected
                            ? null
                            : Border.all(color: GenericColors.borderGrey),
                        borderRadius: BorderRadius.circular(20),
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  GenericColors.bannerBlue1,
                                  GenericColors.bannerBlue3,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                      ),
                      child: BodyTextColors(
                        title: text,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.whiteText
                            : AppColors.darkText,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),
            CustomFullButton(
              title: 'Book this Slot',
              isDialogue: true,
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CustomCalendarWidget extends StatefulWidget {
  const _CustomCalendarWidget();

  @override
  State<_CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<_CustomCalendarWidget> {
  final List<int> fullDates = [13, 17, 18, 22, 27, 28];
  final List<int> freeDates = [
    14,
    15,
    16,
    19,
    20,
    21,
    23,
    24,
    25,
    26,
    29,
    30,
    31,
  ];

  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
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

              Color textColor = AppColors.lightGreyHint;
              Color bgColor = AppColors.whiteText;
              Color borderColor = GenericColors.borderGrey.withValues(
                alpha: .5,
              );

              if (!isPast) {
                if (fullDates.contains(day)) {
                  textColor = GenericColors.darkRed;
                  bgColor = GenericColors.darkRed.withValues(alpha: .09);
                  borderColor = GenericColors.darkRed.withValues(alpha: .2);
                } else if (freeDates.contains(day)) {
                  textColor = GenericColors.darkGreen;
                }
              }

              return GestureDetector(
                onTap: isPast
                    ? null
                    : () {
                        // Implement selection logic here if needed
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
