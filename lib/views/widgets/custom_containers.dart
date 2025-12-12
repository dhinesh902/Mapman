import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/text_styles.dart';

class CustomTextFieldContainer extends StatelessWidget {
  const CustomTextFieldContainer({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 2,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 10),
              BodyTextHint(
                title: title,
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: child
          ),
        ],
      ),
    );
  }
}

class ClearCircleContainer extends StatelessWidget {
  const ClearCircleContainer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GenericColors.darkRed,
          border: Border.all(color: AppColors.whiteText, width: 2),
        ),
        child: Center(
          child: Icon(
            Icons.clear_rounded,
            size: 10,
            color: AppColors.whiteText,
          ),
        ),
      ),
    );
  }
}

class VideoPausePlayCircleContainer extends StatelessWidget {
  const VideoPausePlayCircleContainer({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.whiteText, width: 1),
            color: AppColors.whiteText.withOpacity(0.3),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: AppColors.whiteText),
        ),
      ),
    );
  }
}

class VideoPausePlayGradientCircleContainer extends StatelessWidget {
  const VideoPausePlayGradientCircleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: .5),
                AppColors.darkText.withValues(alpha: .5),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.play_arrow, size: 20, color: AppColors.whiteText),
        ),
      ),
    );
  }
}
