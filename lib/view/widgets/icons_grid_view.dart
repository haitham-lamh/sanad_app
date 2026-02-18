import 'package:flutter/material.dart';
import 'package:sanad_app/constants/constants.dart';

class IconsGridView extends StatefulWidget {
  final Function(int icon, int color) onIconSelected;
  final int? initialIcon;
  final int? initialColor;

  const IconsGridView({
    super.key,
    required this.onIconSelected,
    this.initialIcon,
    this.initialColor,
  });

  @override
  State<IconsGridView> createState() => _IconsGridViewState();
}

class _IconsGridViewState extends State<IconsGridView> {
  int? selectedIndex; // لحفظ الأيقونة المختارة

  @override
  void initState() {
    super.initState();
    _setInitialSelection();
  }

  void _setInitialSelection() {
    if (widget.initialIcon != null) {
      final index = kIcons.indexWhere(
        (item) => (item['icon'] as IconData).codePoint == widget.initialIcon,
      );
      if (index != -1) {
        selectedIndex = index;
        return;
      }
    }
    if (widget.initialColor != null) {
      final index = kIcons.indexWhere(
        (item) => (item['color'] as Color).value == widget.initialColor,
      );
      if (index != -1) {
        selectedIndex = index;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(radius: 6, backgroundColor: Color(0xFF726CC9)),
              SizedBox(width: 8),
              Text(
                'اختر أيقونة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GridView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: kIcons.length,
            itemBuilder: (context, index) {
              final item = kIcons[index];
              final bool isSelected = selectedIndex == index;
      
              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);
                  widget.onIconSelected(
                    (item['icon'] as IconData).codePoint,
                    (item['color'] as Color).value,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: item['border'],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item['color'],
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignCenter,
                    ),
      
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: item['color'],
                                blurRadius: 10,
                                spreadRadius: 1,
                                blurStyle: BlurStyle.outer,
                              ),
                            ]
                            : [],
                  ),
                  child: Icon(item['icon'], size: 36, color: item['color']),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
