import 'package:flutter/material.dart';

// ─── Вспомогательные классы для фильтров ───
class ColorFilterData {
  final String name;
  final Color color;
  final bool isDefault;
  const ColorFilterData(this.name, this.color, this.isDefault);
}

class TypeFilterData {
  final String name;
  final IconData icon;
  const TypeFilterData(this.name, this.icon);
}

class WardrobeFilters extends StatelessWidget {
  final List<ColorFilterData> colorFilters;
  final String? selectedColor;
  final ValueChanged<String?> onColorSelected;

  final List<TypeFilterData> typeFilters;
  final String? selectedType;
  final ValueChanged<String?> onTypeSelected;

  final List<String> seasonTags;
  final String? selectedSeason;
  final ValueChanged<String?> onSeasonSelected;

  const WardrobeFilters({
    super.key,
    required this.colorFilters,
    required this.selectedColor,
    required this.onColorSelected,
    required this.typeFilters,
    required this.selectedType,
    required this.onTypeSelected,
    required this.seasonTags,
    required this.selectedSeason,
    required this.onSeasonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: colorFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final filter = colorFilters[i];
              final isSelected = selectedColor == filter.name;
              return _buildColorChip(filter, isSelected);
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: typeFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final filter = typeFilters[i];
              final isSelected = selectedType == filter.name;
              return _buildTypeChip(filter, isSelected);
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: seasonTags.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final tag = seasonTags[i];
              final isSelected = selectedSeason == tag;
              return _buildSeasonChip(tag, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorChip(ColorFilterData filter, bool isSelected) {
    return GestureDetector(
      onTap: () => onColorSelected(isSelected ? null : filter.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4A5B7) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4A5B7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (filter.color != Colors.transparent) ...[
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: filter.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              filter.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(TypeFilterData filter, bool isSelected) {
    return GestureDetector(
      onTap: () => onTypeSelected(isSelected ? null : filter.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4A5B7) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4A5B7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(filter.icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF666666)),
            const SizedBox(width: 6),
            Text(
              filter.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonChip(String tag, bool isSelected) {
    return GestureDetector(
      onTap: () => onSeasonSelected(isSelected ? null : tag),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4A5B7) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300, width: 0.8),
        ),
        child: Center(
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }
}
