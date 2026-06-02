import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapman/model/shop_detail_model.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/images.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';

class CustomDropDownField extends StatelessWidget {
  const CustomDropDownField({
    super.key,
    required this.title,
    required this.dropdownValue,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.validator,
    this.horizontalPadding = 8,
  });

  final String title;
  final String? dropdownValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final double horizontalPadding;

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
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButtonFormField2(
              isExpanded: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 15,
                ),
              ),
              barrierColor: Colors.transparent,
              iconStyleData: IconStyleData(
                icon: SvgPicture.asset(AppIcons.arrowDropdown, height: 24),
              ),
              dropdownStyleData: DropdownStyleData(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.whiteText,
                  boxShadow: [
                    BoxShadow(
                      color: GenericColors.borderGrey,
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              menuItemStyleData: MenuItemStyleData(
                padding: EdgeInsets.only(left: 15),
              ),
              hint: BodyTextColors(
                title: hintText,
                overflow: TextOverflow.ellipsis,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0Xff1f1f1f1f),
              ),
              value: dropdownValue,
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item.capitalize(),
                    style: AppTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkText,
                    ).textStyle,
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return items.map((String value) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value.capitalize(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText,
                      ).textStyle,
                    ),
                  );
                }).toList();
              },
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}

class ShopsDropDown extends StatelessWidget {
  const ShopsDropDown({
    super.key,
    required this.title,
    required this.dropdownValue,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.validator,
    this.horizontalPadding = 8,
  });

  final String title;
  final ShopDetailData? dropdownValue;
  final List<ShopDetailData> items;
  final ValueChanged<ShopDetailData?> onChanged;
  final String hintText;
  final FormFieldValidator<ShopDetailData>? validator;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 2,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              BodyTextHint(
                title: title,
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ],
          ),

          DropdownButtonHideUnderline(
            child: DropdownButtonFormField2<ShopDetailData>(
              isExpanded: true,
              value: dropdownValue,

              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 15,
                ),
              ),

              barrierColor: Colors.transparent,

              iconStyleData: IconStyleData(
                icon: SvgPicture.asset(AppIcons.arrowDropdown, height: 24),
              ),

              dropdownStyleData: DropdownStyleData(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.whiteText,
                  boxShadow: [
                    BoxShadow(
                      color: GenericColors.borderGrey,
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),

              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.only(left: 15),
              ),

              hint: BodyTextColors(
                title: hintText,
                overflow: TextOverflow.ellipsis,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xff1f1f1f),
              ),

              onChanged: onChanged,

              items: items.map((item) {
                return DropdownMenuItem<ShopDetailData>(
                  value: item,
                  child: Text(
                    item.shopName?.capitalize() ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkText,
                    ).textStyle,
                  ),
                );
              }).toList(),

              selectedItemBuilder: (context) {
                return items.map((item) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.shopName?.capitalize() ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText,
                      ).textStyle,
                    ),
                  );
                }).toList();
              },

              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}
