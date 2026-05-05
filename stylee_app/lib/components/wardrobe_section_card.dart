import 'package:flutter/material.dart';
import 'package:stylee_app/models/wardrobe_item.dart';
import 'package:stylee_app/models/wardrobe_section.dart';

/// Карточка секции гардероба с полным UI
///
/// Параметры режима:
/// - `isEditing` — режим редактирования (крестики, кнопки)
/// - `section` — данные секции
/// - `items` — вещи в секции
/// - `onDelete` — удаление сектора
/// - `onItemTap` — нажатие на вещь
/// - `onEmptyTap` — нажатие на пустое место (создание вещи)
/// - `onItemLongPress` — длительное нажатие (перемещение)
class WardrobeSectionCard extends StatelessWidget {
  final WardrobeSection section;
  final List<WardrobeItem> items;
  final bool isEditing;
  final VoidCallback? onDelete;
  final Function(WardrobeItem item)? onItemTap;
  final Function(WardrobeItem item)? onItemLongPress;
  final VoidCallback? onEmptyTap;
  final bool isFirst; // для drag&drop
  final bool isLast;

  const WardrobeSectionCard({
    super.key,
    required this.section,
    required this.items,
    this.isEditing = false,
    this.onDelete,
    this.onItemTap,
    this.onItemLongPress,
    this.onEmptyTap,
    this.isFirst = true,
    this.isLast = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          items.isEmpty
              ? _buildEmptyState()
              : SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, i) => _buildItemCard(items[i], i),
                  ),
                ),
        ],
      ),
    );
  }

  // ─── Заголовок секции ───

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(section.iconColor).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  section.icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                section.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                  letterSpacing: 0.1,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: items.isEmpty ? null : () {},
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFFD4A5B7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // Кнопка удаления — только в режиме редактирования и не системная
          if (isEditing && !section.isSystem)
            Positioned(
              top: -4,
              right: 0,
              child: GestureDetector(
                onTap: () => _showDeleteConfirmation(context),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Карточка вещи ───

  Widget _buildItemCard(WardrobeItem item, int index) {
    return GestureDetector(
      onTap: () => onItemTap?.call(item),
      onLongPress: () => onItemLongPress?.call(item),
      child: _buildCardInner(item, index),
    );
  }

  Widget _buildCardInner(WardrobeItem item, int index) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isEditing ? 0.7 : 1.0,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null && progress.cumulativeBytesLoaded != null
                              ? progress.cumulativeBytesLoaded! / progress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: const Color(0xFFD4A5B7),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 30),
                  );
                },
              ),
              // Градиент снизу
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Сердечко
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Color(0xFFD4A5B7),
                  ),
                ),
              ),
              // Номер
              Positioned(
                bottom: 8,
                left: 10,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              // Кнопка перемещения в режиме редактирования
              if (isEditing)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.swap_horiz,
                      size: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Пустое состояние ───

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: onEmptyTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 36,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Здесь пока нет вещей.\nДобавьте первую!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Подтверждение удаления ───

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Удалить папку?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Удалить папку "${section.name}"? Все вещи внутри останутся в общем списке.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
