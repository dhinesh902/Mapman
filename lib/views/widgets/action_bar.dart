import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';

class ActionBar extends StatelessWidget implements PreferredSizeWidget {
  const ActionBar({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      surfaceTintColor: AppColors.scaffoldBackgroundDark,
      centerTitle: true,
      toolbarHeight: 55,
      title: HeaderTextBlack(
        title: title,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () {
          context.pop();
        },
        child: Container(
          height: 49,
          width: 52,
          margin: EdgeInsets.fromLTRB(8, 5, 0, 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusGeometry.circular(3),
            color: AppColors.scaffoldBackground,
          ),
          child: Center(
            child: SvgPicture.asset(AppIcons.arrowBack, height: 30, width: 30),
          ),
        ),
      ),
      actions: action != null ? [action!] : null,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(55);
}

class ActionBarComponent extends StatelessWidget {
  const ActionBarComponent({
    super.key,
    required this.title,
    this.action,
    this.titleColor = AppColors.whiteText,
  });

  final String title;
  final Widget? action;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      leading: GestureDetector(
        onTap: () {
          context.pop();
        },
        child: Container(
          height: 48,
          width: 49,
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: SvgPicture.asset(AppIcons.arrowBack, height: 30, width: 30),
          ),
        ),
      ),
      title: BodyTextColors(
        title: title,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: titleColor,
      ),
      trailing: action,
    );
  }
}
