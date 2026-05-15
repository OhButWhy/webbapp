import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stylee_app/models/test_result.dart';
import 'package:stylee_app/models/wardrobe_item.dart';
import 'package:stylee_app/models/wardrobe_section.dart';
import 'package:stylee_app/services/wardrobe_service.dart';
import 'package:stylee_app/components/wardrobe_section_card.dart';
import 'package:stylee_app/components/create_section_dialog.dart';
import 'package:stylee_app/components/section_picker_dialog.dart';
import 'package:stylee_app/screens/quiz/quiz_wizard.dart';

class WardrobePage extends StatefulWidget {
  final VoidCallback? onBackRequested;

  const WardrobePage({super.key, this.onBackRequested});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  final _wardrobeService = WardrobeService();
  final _searchController = TextEditingController();

  String? selectedColor;
  String? selectedType;
  String? selectedSeason;
  String searchQuery = '';
  bool hasCompletedTest = false;

  bool _isEditingSections = false;
  List<WardrobeSection> _sections = [];
  Map<String, List<WardrobeItem>> _itemsBySection = {};
  bool _isLoading = true;
  final _picker = ImagePicker();

  // ─── Цвета для фильтра ───
  final List<_ColorFilter> _colorFilters = const [
    _ColorFilter('All', Colors.transparent, true),
    _ColorFilter('Pink', Color(0xFFE8A0BF), false),
    _ColorFilter('Black', Colors.black87, false),
    _ColorFilter('Brown', Color(0xFF8D6E63), false),
    _ColorFilter('Beige', Color(0xFFD7CCC8), false),
    _ColorFilter('Grey', Color(0xFF9E9E9E), false),
  ];

  // ─── Типы одежды ───
  final List<_TypeFilter> _typeFilters = const [
    _TypeFilter('All', Icons.watch_outlined),
    _TypeFilter('Tops', Icons.check_circle_outline),
    _TypeFilter('Shirts', Icons.shelves),
    _TypeFilter('Dresses', Icons.checkroom),
    _TypeFilter('Skirts', Icons.pregnant_woman),
    _TypeFilter('Pants', Icons.accessibility_new),
  ];

  // ─── Сезоны / стили ───
  final List<String> _seasonTags = [
    'Summer 2026',
    'Casual',
    'Formal',
    'Seasonal',
    'Spring',
    'Autumn',
  ];

  @override
  void initState() {
    super.initState();
    _loadTestData();
    _loadWardrobe();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTestData() async {
    try {
      final doc = await usersCollection.doc(currentUser.email).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          hasCompletedTest = doc.data()!['hasCompletedTest'] == true;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  /// Загрузка секций и вещей из Firebase
  Future<void> _loadWardrobe() async {
    try {
      final sectionsSnapshot = await _wardrobeService
          .sectionsCollection
          .orderBy('order')
          .get();

      final itemsSnapshot = await _wardrobeService
          .itemsCollection
          .orderBy('addedAt', descending: true)
          .get();

      final sections = sectionsSnapshot.docs
          .map((doc) => WardrobeSection.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      final allItems = itemsSnapshot.docs
          .map((doc) => WardrobeItem.fromFirestore(doc))
          .toList();

      Map<String, List<WardrobeItem>> grouped = {};
      for (var item in allItems) {
        grouped.putIfAbsent(item.sectionId, () => []).add(item);
      }

      setState(() {
        _sections = sections;
        _itemsBySection = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Перезагрузка секций (после CRUD-операций)
  Future<void> _reloadSections() async {
    try {
      final sectionsSnapshot = await _wardrobeService
          .sectionsCollection
          .orderBy('order')
          .get();

      setState(() {
        _sections = sectionsSnapshot.docs
            .map((doc) => WardrobeSection.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      // ignore
    }
  }

  void _openQuiz(BuildContext context, {TestResult? existingResult}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizWizard(
          existingResult: existingResult,
          onComplete: (newResult) async {
            await usersCollection.doc(currentUser.email).update({
              'testResult': newResult.toMap(),
              'hasCompletedTest': true,
            });
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8EAEF),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilters(),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          children: [
                            _buildQuizCard(context),
                            const SizedBox(height: 24),
                            if (_isEditingSections) ...[
                              // Кнопка создания новой секции
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: InkWell(
                                  onTap: () => _showCreateSection(),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFD4A5B7),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_circle_outline, color: Color(0xFFD4A5B7)),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Создать новую папку',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFD4A5B7),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ] else ...[
                              // Перетаскивание секций (ReorderableListView)
                              ReorderableListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _sections.length,
                                onReorder: (oldIndex, newIndex) {
                                  if (oldIndex == newIndex) return;
                                  int targetIndex = newIndex;
                                  if (oldIndex < newIndex) targetIndex = newIndex - 1;

                                  setState(() {
                                    final item = _sections.removeAt(oldIndex);
                                    _sections.insert(targetIndex, item);
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final section = _sections[index];
                                  final items = _itemsBySection[section.id] ?? [];
                                  return Container(
                                    key: ValueKey(section.id),
                                    child: WardrobeSectionCard(
                                      section: section,
                                      items: items,
                                      isEditing: false,
                                      onEmptyTap: () => _showImagePicker(section.id),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildAddButton(),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  ШАПКА
  // ═══════════════════════════════════════════════

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.onBackRequested != null) {
                widget.onBackRequested!();
                return;
              }
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios, size: 18),
            ),
          ),
          Column(
            children: [
              const Text(
                'My Wardrobe',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                  letterSpacing: 0.3,
                ),
              ),
              // Индикатор режима редактирования
              if (_isEditingSections)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) => AnimatedOpacity(
                    opacity: value,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A5B7).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Режим редактирования',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFD4A5B7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isEditingSections)
                GestureDetector(
                  onTap: () => setState(() => _isEditingSections = true),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF333333)),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => setState(() {
                    _isEditingSections = false;
                    _reloadSections();
                  }),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A5B7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A5B7).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, size: 18, color: Colors.white),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.tune_outlined, size: 20, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _colorFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final filter = _colorFilters[i];
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
            itemCount: _typeFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final filter = _typeFilters[i];
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
            itemCount: _seasonTags.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final tag = _seasonTags[i];
              final isSelected = selectedSeason == tag;
              return _buildSeasonChip(tag, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorChip(_ColorFilter filter, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedColor = isSelected ? null : filter.name),
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
                    color: const Color(0xFFD4A5B7).withValues(alpha: 0.3),
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

  Widget _buildTypeChip(_TypeFilter filter, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedType = isSelected ? null : filter.name),
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
                    color: const Color(0xFFD4A5B7).withValues(alpha: 0.3),
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
      onTap: () => setState(() => selectedSeason = isSelected ? null : tag),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4A5B7) : Colors.white.withValues(alpha: 0.7),
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

  Widget _buildQuizCard(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: hasCompletedTest ? usersCollection.doc(currentUser.email).get() : null,
      builder: (context, snapshot) {
        TestResult? existingResult;
        if (hasCompletedTest && snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data['testResult'] != null) {
            existingResult = TestResult.fromMap(data['testResult'] as Map<String, dynamic>);
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => _openQuiz(context, existingResult: existingResult),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8A0BF), Color(0xFFE8A0BF), Color(0xFFFFC1D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8A0BF).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_fix_high_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasCompletedTest
                              ? 'Перепройти тест персонализации'
                              : 'Тест персонализации',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasCompletedTest
                              ? 'Обновите свой стиль и получайте точные рекомендации'
                              : 'Узнайте свой стиль — AI подберёт образы',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════
  //  FAB — Добавить вещь
  // ═══════════════════════════════════════════════

  Widget _buildAddButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton(
        onPressed: _showAddItemMenu,
        backgroundColor: const Color(0xFFD4A5B7),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  /// Кнопка «+» — выбрать секцию, добавить вещь.
  Future<void> _showAddItemMenu() async {
    final allSections = [
      WardrobeSection.general(id: WardrobeService.generalSectionId),
      ..._sections,
    ];
    final selected = await showSectionPickerDialog(
      context: context,
      sections: allSections,
      currentSectionId: null,
    );
    if (selected == null || !mounted) return;
    await _showImagePicker(selected.id);
  }

  /// Диалог выбора изображения (камера / галерея).
  Future<void> _showImagePicker(String targetSectionId) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Добавить вещь',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BuildOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Камера',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(ImageSource.camera, targetSectionId);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BuildOptionButton(
                    icon: Icons.photo_library,
                    label: 'Галерея',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(ImageSource.gallery, targetSectionId);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source, String sectionId) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 800,
    );
    if (picked == null) return;

    // В MVP: сохраняем как placeholder. В продакшене — upload в Firebase Storage.
    final tempUrl = picked.path;
    final result = await _showItemNameDialog(context, picked.name.split('/').last);
    if (!mounted || result == null) return;

    await _wardrobeService.addItem(
      imageUrl: tempUrl,
      name: result.isEmpty ? picked.name.split('/').last : result,
      sectionId: sectionId,
      tags: [],
    );
    _reloadSections();
    _loadWardrobe();
  }

  Future<String?> _showItemNameDialog(BuildContext context, String defaultName) async {
    final controller = TextEditingController(text: defaultName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Название вещи', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Например: Синее платье', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Готово')),
        ],
      ),
    );
    return result;
  }

  /// Создать новую секцию.
  Future<void> _showCreateSection() async {
    await showCreateSectionDialog(
      context: context,
      service: _wardrobeService,
      onSuccess: () {
        setState(() {}); // обновить UI — StreamBuilder подтянет
        _reloadSections();
      },
    );
  }
}

// ═══════════════════════════════════════════════
//  ВСПОМОГАТЕЛЬНЫЕ КЛАССЫ
// ═══════════════════════════════════════════════

class _ColorFilter {
  final String name;
  final Color color;
  final bool isDefault;
  const _ColorFilter(this.name, this.color, this.isDefault);
}

class _TypeFilter {
  final String name;
  final IconData icon;
  const _TypeFilter(this.name, this.icon);
}

/// Кнопка выбора действия (камера / галерея)
class _BuildOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BuildOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFFD4A5B7)),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
            ),
          ],
        ),
      ),
    );
  }
}
