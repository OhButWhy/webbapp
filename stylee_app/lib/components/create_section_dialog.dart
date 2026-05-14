import 'package:flutter/material.dart';
import 'package:stylee_app/services/wardrobe_service.dart';

/// Предопределённые иконки и цвета для секций
class SectionStyleOptions {
  static const List<String> icons = [
    '👗', '👠', '💼', '✈️', '❤️', '🧘‍♀️', '👟', '🧥',
    '👔', '🩳', '👒', '👜', '🕶️', '💍', '🎒', '👙',
  ];

  static const List<int> colors = [
    0xFFD4A5B7,
    0xFF9575CD,
    0xFFFFB74D,
    0xFF4DD0E1,
    0xFF81C784,
    0xFFA1887F,
    0xFF7986CB,
    0xFFFF8A65,
    0xFFBA68C8,
    0xFF4DB6AC,
  ];

  static Map<int, Color> get colorMap => {
        for (var color in colors) color: Color(color),
      };
}

/// Модальное окно создания новой секции
Future<bool> showCreateSectionDialog({
  required BuildContext context,
  required WardrobeService service,
  required VoidCallback onSuccess,
}) async {
  final controller = TextEditingController();
  String selectedIcon = '👗';
  int selectedColor = 0xFFD4A5B7;
  bool isLoading = false;

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              const Row(
                children: [
                  Text(
                    'Новая папка',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: null,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Поле названия
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 30,
                decoration: InputDecoration(
                  labelText: 'Название папки',
                  hintText: 'Например: Для йоги',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterStyle: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              // Выбор иконки
              const Text(
                'Иконка',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: SectionStyleOptions.icons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final icon = SectionStyleOptions.icons[i];
                    final isSelected = icon == selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFD4A5B7)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD4A5B7)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Выбор цвета
              const Text(
                'Цвет',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: SectionStyleOptions.colors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final color = SectionStyleOptions.colors[i];
                    final isSelected = color == selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD4A5B7)
                                : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(color).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading || controller.text.trim().isEmpty
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              final name = controller.text.trim();
                              if (name.isNotEmpty) {
                                await service.createSection(
                                  name: name,
                                  icon: selectedIcon,
                                  iconColor: selectedColor,
                                );
                                if (context.mounted) {
                                  Navigator.of(context).pop(true);
                                  onSuccess();
                                }
                              }
                              setState(() => isLoading = false);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A5B7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Создать',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );

  return result == true;
}
