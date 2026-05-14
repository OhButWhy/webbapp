import 'package:flutter/material.dart';
import '../models/test_result.dart';

class OnboardingTestScreen extends StatefulWidget {
  final void Function(TestResult result) onComplete;
  const OnboardingTestScreen({super.key, required this.onComplete});

  @override
  State<OnboardingTestScreen> createState() => _OnboardingTestScreenState();
}

class _OnboardingTestScreenState extends State<OnboardingTestScreen> {
  final _formKey = GlobalKey<FormState>();



  double? _height;
  double? _bust;
  double? _waist;
  double? _hips;
  String? _city;
  List<String> _preferredStyles = [];
  List<String> _favoriteColors = [];
  List<String> _avoidedColors = [];
  String? _fitPreference;
  String? _specialNotes;

  final List<String> styles = [
    'Классический', 'Кэжуал', 'Спорт-шик', 'Бохо', 'Минимализм', 'Зондбе', 'Авангард', 'Другое'
  ];
  final List<String> fitOptions = ['Свободная', 'Средняя', 'Облегающая'];
  final List<String> colorOptions = [
    'Чёрный', 'Белый', 'Серый', 'Бежевый', 'Синий', 'Голубой', 'Зелёный', 'Красный', 'Жёлтый', 'Розовый', 'Фиолетовый', 'Коричневый', 'Оранжевый', 'Другой'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тест персонализации')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              Text('Ваши предпочтительные стили (можно выбрать несколько):'),
              ...styles.map((s) => CheckboxListTile(
                title: Text(s),
                value: _preferredStyles.contains(s),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _preferredStyles.add(s);
                    } else {
                      _preferredStyles.remove(s);
                    }
                  });
                },
              )),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Город (или регион)'),
                onChanged: (val) => _city = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Рост (см)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _height = double.tryParse(val),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Обхват груди (см)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _bust = double.tryParse(val),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Обхват талии (см)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _waist = double.tryParse(val),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Обхват бёдер (см)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _hips = double.tryParse(val),
              ),
              // Убрано поле цвет глаз
              const SizedBox(height: 16),
              Text('Любимые цвета (можно выбрать несколько):'),
              ...colorOptions.map((c) => CheckboxListTile(
                title: Text(c),
                value: _favoriteColors.contains(c),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _favoriteColors.add(c);
                    } else {
                      _favoriteColors.remove(c);
                    }
                  });
                },
              )),
              const SizedBox(height: 16),
              Text('Избегаемые цвета/принты (можно выбрать несколько):'),
              ...colorOptions.map((c) => CheckboxListTile(
                title: Text(c),
                value: _avoidedColors.contains(c),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _avoidedColors.add(c);
                    } else {
                      _avoidedColors.remove(c);
                    }
                  });
                },
              )),
              const SizedBox(height: 16),
              Text('Предпочтительная посадка:'),
              ...fitOptions.map((fit) => RadioListTile<String>(
                title: Text(fit),
                value: fit,
                groupValue: _fitPreference,
                onChanged: (val) => setState(() => _fitPreference = val),
              )),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Особые пожелания (опционально)'),
                onChanged: (val) => _specialNotes = val,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final result = TestResult(
                    height: _height,
                    bust: _bust,
                    waist: _waist,
                    hips: _hips,
                    city: _city,
                    preferredStyles: _preferredStyles,
                    favoriteColors: _favoriteColors,
                    avoidedColors: _avoidedColors,
                    fitPreference: _fitPreference,
                    specialNotes: _specialNotes,
                  );
                  widget.onComplete(result);
                },
                child: const Text('Сохранить и продолжить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
