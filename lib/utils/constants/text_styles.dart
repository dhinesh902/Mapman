import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapman/utils/constants/color_constants.dart';

class HeaderTextBlack extends StatelessWidget {
  const HeaderTextBlack({
    super.key,
    required this.title,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.textDecoration = TextDecoration.none,
    this.overflow = TextOverflow.visible,
    this.maxLines,
    this.textAlign,
    this.decorationColor,
  });

  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final TextDecoration textDecoration;
  final TextOverflow overflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? decorationColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      style: GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.darkText,
        decoration: textDecoration,
        decorationColor: decorationColor,
      ),
    );
  }
}

class HeaderTextPrimary extends StatelessWidget {
  const HeaderTextPrimary({
    super.key,
    required this.title,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.textDecoration = TextDecoration.none,
    this.overflow = TextOverflow.visible,
    this.maxLines,
    this.textAlign,
    this.decorationColor,
  });

  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final TextDecoration textDecoration;
  final TextOverflow overflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? decorationColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      style: GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.primary,
        decoration: textDecoration,
        decorationColor: decorationColor,
      ),
    );
  }
}

class BodyTextHint extends StatelessWidget {
  const BodyTextHint({
    super.key,
    required this.title,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.overflow = TextOverflow.visible,
    this.textAlign = TextAlign.start,
    this.maxLines,
  });

  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: overflow,
      textAlign: textAlign,
      maxLines: maxLines,
      style: GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.darkGrey,
      ),
    );
  }
}

class BodyTextColors extends StatelessWidget {
  const BodyTextColors({
    super.key,
    required this.title,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
    required this.color,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.visible,
  });

  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      overflow: overflow,
      style: GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

class HeaderTextWithReq extends StatelessWidget {
  const HeaderTextWithReq({super.key, required this.title, this.isReq = true});

  final String title;
  final bool isReq;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      textAlign: TextAlign.start,
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.darkText,
            ),
          ),
          TextSpan(
            text: isReq ? ' *' : '',
            style: GoogleFonts.outfit(fontSize: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class OutlineText extends StatelessWidget {
  const OutlineText({super.key, required this.title, required this.fontSize});

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.scaffoldBackgroundDark,
        shadows: [
          Shadow(
            blurRadius: 0,
            color: Colors.grey.shade400,
            offset: Offset(1, 1),
          ),
          Shadow(
            blurRadius: 0,
            color: Colors.grey.shade400,
            offset: Offset(-1, 1),
          ),
          Shadow(
            blurRadius: 0,
            color: Colors.grey.shade400,
            offset: Offset(1, -1),
          ),
          Shadow(
            blurRadius: 0,
            color: Colors.grey.shade400,
            offset: Offset(-1, -1),
          ),
        ],
      ),
    );
  }
}

class AppTextStyle {
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final Color? decorationColor;
  final TextDecoration? decoration;

  AppTextStyle({
    required this.fontSize,
    required this.fontWeight,
    this.decoration,
    this.decorationColor,
    required this.color,
  });

  TextStyle get textStyle => GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    decoration: decoration,
    decorationColor: decorationColor,
    color: color,
  );
}


class EndMessageSection extends StatelessWidget {
  final String title;
  final double titleSize;
  final Color iconColor;

  const EndMessageSection({
    super.key,
    required this.title,
    this.titleSize = 20,
    this.iconColor = const Color(0xFFB00020),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        OutlineText(title: title, fontSize: titleSize),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(
              CupertinoIcons.heart_fill,
              size: 14,
              color: iconColor,
            ),
            const SizedBox(width: 10),
            BodyTextHint(
              title: 'You made it to the end...',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ],
    );
  }
}