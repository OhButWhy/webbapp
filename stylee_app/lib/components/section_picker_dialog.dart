import 'package:flutter/material.dart';
import 'package:stylee_app/models/wardrobe_section.dart';

/// Диалог выбора секции для перемещения/добавления вещи
Future<WardrobeSection?> showSectionPickerDialog({
  required BuildContext context,
  required List<WardrobeSection> sections,
  currentSectionId,
}) async {
  return showModalBottomSheet<WardrobeSection?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Выберите папку',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Список секций
            SizedBox(
              height: sections.length * 52 + 40,
              child: ListView(
                children: [
                  ...sections.map((section) {
                    final isSelected = section.id == currentSectionId;
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pop(section);
                      },
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(section.iconColor).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(section.icon, style: const TextStyle(fontSize: 20)),
                      ),
                      title: Text(
                        section.id == 'general' ? 'Общий список' : '${section.icon} ${section.name}',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFD4A5B7) : const Color(0xFF333333),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFFD4A5B7))
                          : null,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
