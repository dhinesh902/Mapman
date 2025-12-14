import 'package:flutter/material.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ButtonProgressBar extends StatelessWidget {
  const ButtonProgressBar({super.key, this.isLogin = false});

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isLogin ? 0 : 10),
        child: ElevatedButton(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size.fromRadius(23)),
            shape: WidgetStateProperty.all(const CircleBorder()),
            backgroundColor: WidgetStatePropertyAll(AppColors.primary),
          ),
          onPressed: null,
          child: const SizedBox(
            height: 23,
            width: 23,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: AppColors.scaffoldBackground,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomFullButton extends StatelessWidget {
  const CustomFullButton({
    super.key,
    required this.title,
    required this.onTap,
    this.borderRadius = 4,
    this.isDialogue = false,
    this.color = AppColors.primary,
  });

  final String title;
  final VoidCallback onTap;
  final double borderRadius;
  final bool isDialogue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: double.maxFinite,
        margin: isDialogue
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: color,
        ),
        child: Center(
          child: BodyTextColors(
            title: title,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteText,
          ),
        ),
      ),
    );
  }
}

class GetStartedButton extends StatelessWidget {
  const GetStartedButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: double.maxFinite,
        margin: EdgeInsets.symmetric(horizontal: 45, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.primary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: MediaQuery.of(context).size.width * .25),
            BodyTextColors(
              title: "Get started",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteText,
            ),
            Spacer(),
            Icon(
              Icons.keyboard_arrow_right_outlined,
              color: AppColors.whiteText,
            ),
            SizedBox(width: 50),
          ],
        ),
      ),
    );
  }
}

class CustomOutlineButtonWithImage extends StatelessWidget {
  const CustomOutlineButtonWithImage({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isGoogle = true,
  });

  final String title, icon;
  final VoidCallback onTap;
  final bool isGoogle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: double.maxFinite,
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // color: AppColors.scaffoldBackground,
          border: Border.all(color: GenericColors.borderGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle) ...[
              SvgPicture.asset(icon, height: 24, width: 24),
            ] else ...[
              Image.asset(icon, height: 24, width: 24),
            ],
            SizedBox(width: 20),
            HeaderTextBlack(
              title: title,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: double.maxFinite,
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.scaffoldBackground,
          border: Border.all(color: AppColors.darkText),
        ),
        child: Center(
          child: BodyTextHint(
            title: title,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.circular(6),
          color: AppColors.primary,
        ),
        child: Center(
          child: BodyTextColors(
            title: title,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteText,
          ),
        ),
      ),
    );
  }
}

class GetRewardButton extends StatelessWidget {
  const GetRewardButton({super.key, required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0XFFFF9202),
              Color(0XFFFF9202),
              Color(0XFFF9A83D),
              Color(0XFFB16500),
            ],
          ),
        ),
        child: Center(
          child: BodyTextColors(
            title: title,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }
}
