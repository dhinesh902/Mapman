import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/constants/themes.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.title,
    required this.controller,
    required this.hintText,
    this.inputType = TextInputType.text,
    this.validator,
    this.isSameRegisterNumber = false,
    this.isActive = false,
    this.onChanged,
    this.suffixIcon,
    this.onTap,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLength,
    required this.inputAction,
    this.isReadOnly = false,
  });

  final TextEditingController controller;
  final String title;
  final TextInputType inputType;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final bool isSameRegisterNumber, isActive;
  final Function(bool?)? onChanged;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final TextInputAction inputAction;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
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
              if (isSameRegisterNumber) ...[
                Spacer(),
                BodyTextHint(
                  title: 'Same as Register No',
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
                Checkbox(
                  value: isActive,
                  onChanged: onChanged,
                  visualDensity: VisualDensity(vertical: -3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: AppColors.primary,
                ),
                SizedBox(width: 10),
              ],
            ],
          ),
          TextFormField(
            controller: controller,
            cursorColor: AppColors.primary,
            keyboardType: inputType,
            textCapitalization: textCapitalization,
            textInputAction: inputAction,
            readOnly: isReadOnly,
            maxLength: maxLength,
            onTap: onTap,
            style: AppTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ).textStyle,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              counterText: "",
              hintStyle: AppTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0XFF1F1F1F1F),
              ).textStyle,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 14,
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      size: 18,
                      weight: 700,
                      color: AppColors.darkText,
                    )
                  : null,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.clearOnTap,
    this.onChanged,
    this.focusNode,
     this.ontTap,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback clearOnTap;
  final FocusNode? focusNode;
  final Function(String?)? onChanged;
  final VoidCallback? ontTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: Themes.searchFieldDecoration(),
        clipBehavior: Clip.hardEdge,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: AppColors.primary,
              onTap: ontTap,
              style: AppTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ).textStyle,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                filled: true,
                fillColor: AppColors.scaffoldBackground,
                hintText: hintText,
                hintStyle: AppTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB3B5B7),
                ).textStyle,
                prefixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 12, 0, 12),
                  child: SvgPicture.asset(
                    AppIcons.search,
                    colorFilter: ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                suffixIcon: value.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(13),
                        child: GestureDetector(
                          onTap: clearOnTap,
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: GenericColors.darkRed,
                              border: Border.all(
                                color: AppColors.whiteText,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.clear_rounded,
                              size: 12,
                              color: AppColors.whiteText,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              onChanged: onChanged,
            );
          },
        ),
      ),
    );
  }
}
