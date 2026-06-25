import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/text_styles.dart';

class CustomTimePicker {
  static Future<TimeOfDay?> pickReturnTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: ThemeData(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textTheme: textTheme,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
              useMaterial3: false,
            ),
            child: child!,
          ),
        );
      },
    );

    return pickedTime;
  }

  static Future<TimeOfDay?> showScrollableTimePicker(
    BuildContext context,
  ) async {
    DateTime selectedTime = DateTime.now();

    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.whiteText,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HeaderTextBlack(
                  title: 'Select Time',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 180,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: AppTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ).textStyle,
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: false,
                      initialDateTime: selectedTime,
                      onDateTimeChanged: (DateTime newTime) {
                        selectedTime = newTime;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: GenericColors.borderGrey),
                          ),
                        ),
                        child: BodyTextColors(
                          title: 'Cancel',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: GenericColors.darkRed,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            TimeOfDay(
                              hour: selectedTime.hour,
                              minute: selectedTime.minute,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.lightGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: BodyTextColors(
                          title: 'Done',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result;
  }

  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.outfit(),
    displaySmall: GoogleFonts.outfit(),
    displayMedium: GoogleFonts.outfit(),
    titleSmall: GoogleFonts.outfit(),
    titleMedium: GoogleFonts.outfit(),
    titleLarge: GoogleFonts.outfit(),
    bodySmall: GoogleFonts.outfit(),
    bodyLarge: GoogleFonts.outfit(),
    bodyMedium: GoogleFonts.outfit(),
    labelLarge: GoogleFonts.outfit(),
    labelMedium: GoogleFonts.outfit(),
    labelSmall: GoogleFonts.outfit(),
  );
}
