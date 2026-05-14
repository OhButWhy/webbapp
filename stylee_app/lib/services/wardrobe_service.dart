import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylee_app/models/wardrobe_item.dart';
import 'package:stylee_app/models/wardrobe_section.dart';

/// Сервис для управления секциями и вещами гардероба
/// Сохраняет структуру в Firestore + кеширует в SharedPreferences
class WardrobeService {
  final usersCollection = FirebaseFirestore.instance.collection('Users');

  /// ID системной секции «Общий список»
  static const String generalSectionId = 'general';

  /// Текущий пользователь
  User? get _user => FirebaseAuth.instance.currentUser;

  /// Путь к коллекции пользователя
  CollectionReference get sectionsCollection =>
      usersCollection.doc(_user?.email).collection('wardrobe_sections');
  CollectionReference get itemsCollection =>
      usersCollection.doc(_user?.email).collection('wardrobe_items');

  // ───────────────────────────────────────
  //  ЗАГРУЗКА СТРУКТУРЫ
  // ───────────────────────────────────────

  /// Загрузить все кастомные секции
  /// Порядок: сначала general (system), потом кастомные по order
  Stream<List<WardrobeSection>> watchSections() async* {
    await for (var snapshot in sectionsCollection.orderBy('order').snapshots()) {
      final sections = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return WardrobeSection.fromMap(data);
          })
          .toList();

      yield sections;
    }
  }

  /// Загрузить все вещи пользователя
  Stream<List<WardrobeItem>> watchItems() {
    return itemsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => WardrobeItem.fromFirestore(doc))
          .toList();
    });
  }

  // ───────────────────────────────────────
  //  УПРАВЛЕНИЕ СЕКЦИЯМИ
  // ───────────────────────────────────────

  /// Создать новую кастомную секцию
  Future<String> createSection({
    required String name,
    String icon = '👗',
    int iconColor = 0xFFD4A5B7,
  }) async {
    final userId = _user?.uid;
    if (userId == null) throw Exception('Пользователь не авторизован');

    // Генерируем новый уникальный ID
    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    // Получаем текущий максимальный order
    final maxOrder = await _getMaxOrder();

    final section = WardrobeSection.custom(
      id: newId,
      name: name,
      icon: icon,
      iconColor: iconColor,
      order: maxOrder + 1,
    );

    await sectionsCollection.doc(newId).set(section.toMap());
    await _saveStructureLocally();

    return newId;
  }

  /// Удалить секцию (вещи остаются, просто меняется sectionId на general)
  Future<void> deleteSection(String sectionId) async {
    if (sectionId == generalSectionId) {
      throw Exception('Нельзя удалить системную секцию');
    }

    // Перемещаем все вещи из этой секции в «Общий список»
    final itemsSnapshot = await itemsCollection
        .where('sectionId', isEqualTo: sectionId)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in itemsSnapshot.docs) {
      batch.update(doc.reference, {'sectionId': generalSectionId});
    }
    await batch.commit();

    // Удаляем секцию
    await sectionsCollection.doc(sectionId).delete();
    await _saveStructureLocally();
  }

  /// Обновить порядок секций (после drag&drop)
  Future<void> reorderSections(List<String> orderedIds) async {
    final batch = FirebaseFirestore.instance.batch();
    int idx = 0;
    for (var id in orderedIds) {
      batch.update(sectionsCollection.doc(id), {'order': idx});
      idx++;
    }
    await batch.commit();
    await _saveStructureLocally();
  }

  /// Обновить название секции
  Future<void> updateSectionName(String sectionId, String newName) async {
    final cleanName = newName.length > 30 ? newName.substring(0, 30) : newName;
    await sectionsCollection.doc(sectionId).update({'name': cleanName});
  }

  /// Обновить иконку секции
  Future<void> updateSectionIcon(String sectionId, String newIcon) async {
    await sectionsCollection.doc(sectionId).update({'icon': newIcon});
  }

  // ───────────────────────────────────────
  //  УПРАВЛЕНИЕ ВЕЩАМИ
  // ───────────────────────────────────────

  /// Добавить вещь в указанную секцию
  Future<String> addItem({
    required String imageUrl,
    String name = '',
    String sectionId = 'general',
    List<String> tags = const [],
  }) async {
    if (sectionId == generalSectionId ||
        (await _sectionExists(sectionId))) {
      // Секция существует — добавляем вещь туда
    } else if (await _sectionExists(generalSectionId)) {
      // Если указанная секция не найдена — общий список
      sectionId = generalSectionId;
    } else {
      sectionId = generalSectionId;
    }

    final itemId = DateTime.now().millisecondsSinceEpoch.toString();
    final item = WardrobeItem(
      id: itemId,
      imageUrl: imageUrl,
      name: name,
      sectionId: sectionId,
      tags: tags,
      addedAt: DateTime.now(),
    );

    await itemsCollection.doc(itemId).set(item.toMap());
    return itemId;
  }

  /// Удалить вещь
  Future<void> deleteItem(String itemId) async {
    await itemsCollection.doc(itemId).delete();
  }

  /// Переместить вещь в другую секцию
  Future<void> moveItem(String itemId, String targetSectionId) async {
    if (targetSectionId != generalSectionId &&
        !(await _sectionExists(targetSectionId))) {
      throw Exception('Целевая секция не найдена');
    }
    await itemsCollection.doc(itemId).update({'sectionId': targetSectionId});
  }

  /// Добавить тег(и) к вещи
  Future<void> addTags(String itemId, List<String> newTags) async {
    await itemsCollection.doc(itemId).update({
      'tags': FieldValue.arrayUnion(newTags),
    });
  }

  // ───────────────────────────────────────
  //  ПОЛУЧЕНИЕ ДАННЫХ (однократные)
  // ───────────────────────────────────────

  /// Получить одну секцию
  Future<WardrobeSection?> getSection(String sectionId) async {
    final doc = await sectionsCollection.doc(sectionId).get();
    if (!doc.exists) return null;
    return WardrobeSection.fromMap(doc.data() as Map<String, dynamic>);
  }

  /// Вещи в одной секции
  Future<List<WardrobeItem>> getItemsInSection(String sectionId) async {
    final snapshot = await itemsCollection
        .where('sectionId', isEqualTo: sectionId)
        .orderBy('addedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => WardrobeItem.fromFirestore(doc)).toList();
  }

  /// Все вещи пользователя
  Future<List<WardrobeItem>> getAllItems() async {
    final snapshot = await itemsCollection
        .orderBy('addedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => WardrobeItem.fromFirestore(doc)).toList();
  }

  /// Все вещи для отображения в UI (combined с секциями)
  Future<List<Map<String, dynamic>>> getWardrobeWithSections() async {
    final sectionsSnapshot = await sectionsCollection.orderBy('order').get();
    final itemsSnapshot = await itemsCollection.orderBy('addedAt', descending: true).get();

    final sections = sectionsSnapshot.docs
        .map((doc) => WardrobeSection.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    final items = itemsSnapshot.docs
        .map((doc) => WardrobeItem.fromFirestore(doc))
        .toList();

    // Группируем вещи по секциям
    Map<String, List<WardrobeItem>> grouped = {
      generalSectionId: items.where((i) => i.sectionId == generalSectionId).toList(),
    };
    for (var section in sections) {
      grouped[section.id] = items
          .where((i) => i.sectionId == section.id)
          .toList();
    }

    // Добавляем системную секцию в начало
    final general = WardrobeSection.general(id: generalSectionId);
    final result = <Map<String, dynamic>>[];
    result.add({
      'section': general,
      'items': grouped[generalSectionId] ?? [],
    });
    for (var section in sections) {
      result.add({
        'section': section,
        'items': grouped[section.id] ?? [],
      });
    }

    return result;
  }

  // ───────────────────────────────────────
  //  ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ───────────────────────────────────────

  Future<bool> _sectionExists(String sectionId) async {
    final doc = await sectionsCollection.doc(sectionId).get();
    return doc.exists;
  }

  Future<int> _getMaxOrder() async {
    final snapshot = await sectionsCollection
        .orderBy('order', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return 0;
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return ((data['order'] as num?)?.toInt() ?? 0);
  }

  /// Сохранить структуру локально (кеширование)
  Future<void> _saveStructureLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshot = await sectionsCollection.orderBy('order').get();
      final sections = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      await prefs.setString('wardrobe_structure_backup', sections.toString());
    } catch (e) {
      // Локальное кеширование не критично
    }
  }
}
