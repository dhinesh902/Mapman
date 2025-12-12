import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';

class Themes {
  static BoxDecoration searchFieldDecoration({
    double borderRadius = 20,
    double blurRadius = 4,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: AppColors.scaffoldBackground,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: blurRadius,
          spreadRadius: 0,
          offset: Offset(0, blurRadius),
        ),
      ],
    );
  }
}
