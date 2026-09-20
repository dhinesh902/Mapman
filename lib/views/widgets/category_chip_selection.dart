import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapman/utils/constants/color_constants.dart';
import 'package:mapman/utils/constants/text_styles.dart';
import 'package:mapman/utils/extensions/string_extensions.dart';

class CategoryChipSelection extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String) onSelected;
  final VoidCallback onAddCustom;
  final Function(String)? onDelete;

  const CategoryChipSelection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
    required this.onAddCustom,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> iconMap = [
      'theater',
      'restaurant',
      'hospital',
      'bar',
      'grocery',
      'textile',
      'resort',
      'bunk',
      'jewellery',
      'furniture',
      'salons',
      'spa',
      'hotel',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...categories.map((cat) {
          final isSelected =
              selectedCategory?.toLowerCase() == cat.toLowerCase();
          final isOthers = !iconMap.contains(cat.toLowerCase());

          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => onSelected(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : const Color(0XFFEFF3FD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    cat.capitalize(),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0XFF617193),
                    ),
                  ),
                ),
              ),
              if (isOthers && onDelete != null)
                Positioned(
                  top: -5,
                  right: -5,
                  child: GestureDetector(
                    onTap: () => onDelete!(cat),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: GenericColors.darkRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        GestureDetector(
          onTap: onAddCustom,
          child: CustomPaint(
            painter: DashedBorderPainter(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 16, color: Color(0XFF8FA0C0)),
                  const SizedBox(width: 5),
                  BodyTextColors(
                    title: 'Add custom',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0XFF8FA0C0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const DashedBorderPainter({
    this.borderColor = const Color(0xFF8FA0C0),
    this.borderRadius = 20,
    this.strokeWidth = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rRect);
    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );

        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return borderColor != oldDelegate.borderColor ||
        borderRadius != oldDelegate.borderRadius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashSpace != oldDelegate.dashSpace;
  }
}

class CustomShopDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String hintText;
  final String Function(T item) itemLabel;
  final IconData? hintIcon;
  final IconData? itemIcon;

  const CustomShopDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hintText,
    required this.itemLabel,
    this.hintIcon = Icons.list_alt_outlined,
    this.itemIcon = Icons.circle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.whiteText,
        border: Border.all(
          color: GenericColors.darkGreen.withValues(alpha: .18),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: GenericColors.darkGreen.withValues(alpha: .10),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          value: value,
          isDense: true,
          onChanged: onChanged,
          hint: Row(
            children: [
              Icon(hintIcon, color: GenericColors.darkGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: BodyTextColors(
                  title: hintText,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText.withValues(alpha: .7),
                ),
              ),
            ],
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: BodyTextColors(
                title: itemLabel(item),
                overflow: TextOverflow.ellipsis,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            );
          }).toList(),
          buttonStyleData: const ButtonStyleData(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 15),
            elevation: 0,
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            iconSize: 24,
            iconEnabledColor: AppColors.darkText,
            iconDisabledColor: AppColors.darkText.withValues(alpha: .5),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250,
            padding: EdgeInsets.zero,
            offset: const Offset(0, -5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: GenericColors.darkGreen.withValues(alpha: .18),
                width: 2,
              ),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 15),
          ),
        ),
      ),
    );
  }
}
