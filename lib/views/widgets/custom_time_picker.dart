import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapman/utils/constants/color_constants.dart';

class CustomTimePicker {
  static Future<TimeOfDay?> pickReturnTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
