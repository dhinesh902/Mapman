import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/text_styles.dart';

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 70,
        width: 70,
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeCap: StrokeCap.round,
          strokeWidth: 6,
        ),
      ),
    );
  }
}

class CustomErrorTextWidget extends StatelessWidget {
  const CustomErrorTextWidget({super.key, required this.title, this.color});

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BodyTextColors(
        title: title,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class NoDataText extends StatelessWidget {
  const NoDataText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HeaderTextBlack(
        title: title,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
