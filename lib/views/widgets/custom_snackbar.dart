import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';

class CustomToast {
  static show(
    BuildContext context, {
    required String title,
    bool isError = false,
  }) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.0),
        color: isError ? GenericColors.darkRed : AppColors.primary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isError) Icon(Icons.check, color: AppColors.whiteText, size: 18),
          SizedBox(width: 12.0),
          Flexible(
            child: Text(
              title.capitalize(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.whiteText,
              ),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key, this.height = 60});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: height,
        width: height,
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeCap: StrokeCap.round,
          backgroundColor: AppColors.primaryBorder.withValues(alpha: .2),
          strokeWidth: 8,
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
