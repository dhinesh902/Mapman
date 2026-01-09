import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';

class Themes {
  static BoxDecoration searchFieldDecoration({
    double borderRadius = 20,
    double blurRadius = 4,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: AppColors.scaffoldBackground,
      shape:shape,
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
