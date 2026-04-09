import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/outfit_list.dart';

class OutfitPickerScreen extends StatefulWidget {
  const OutfitPickerScreen({super.key});

  @override
  State<OutfitPickerScreen> createState() => _OutfitPickerScreenState();
}

class _OutfitPickerScreenState extends State<OutfitPickerScreen> {
  String? selectedEvent;
  String? selectedWeather;
  String? selectedColor;
  List<Outfit> filteredOutfits = [];
  bool showResults = false;

  final List<String> eventOptions = [
    'работа', 'вечеринка', 'прогулка'
  ];
  final List<String> weatherOptions = [
    'жарко', 'прохладно', 'дождь'
  ];
  final List<String> colorOptions = [
    'чёрный', 'белый', 'красный', 'синий', 'серый', 'голубой'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подбор образа')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Мероприятие:'),
            DropdownButton<String>(
              value: selectedEvent,
              hint: const Text('Выберите мероприятие'),
              isExpanded: true,
              items: eventOptions.map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              )).toList(),
              onChanged: (val) => setState(() => selectedEvent = val),
            ),
            const SizedBox(height: 16),
            const Text('Погода:'),
            DropdownButton<String>(
              value: selectedWeather,
              hint: const Text('Выберите погоду'),
              isExpanded: true,
              items: weatherOptions.map((w) => DropdownMenuItem(
                value: w,
                child: Text(w),
              )).toList(),
              onChanged: (val) => setState(() => selectedWeather = val),
            ),
            const SizedBox(height: 16),
            const Text('Цвет:'),
            DropdownButton<String>(
              value: selectedColor,
              hint: const Text('Выберите цвет'),
              isExpanded: true,
              items: colorOptions.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              )).toList(),
              onChanged: (val) => setState(() => selectedColor = val),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    filteredOutfits = outfits.where((outfit) {
                      final eventMatch = selectedEvent == null || outfit.events.contains(selectedEvent);
                      final weatherMatch = selectedWeather == null || outfit.weathers.contains(selectedWeather);
                      final colorMatch = selectedColor == null || outfit.colors.contains(selectedColor);
                      return eventMatch && weatherMatch && colorMatch;
                    }).toList();
                    showResults = true;
                  });
                },
                child: const Text('Показать образы'),
              ),
            ),
            const SizedBox(height: 24),
            if (showResults)
              Expanded(
                child: filteredOutfits.isEmpty
                  ? const Center(child: Text('Нет подходящих образов'))
                  : ListView.builder(
                      itemCount: filteredOutfits.length,
                      itemBuilder: (context, idx) {
                        final outfit = filteredOutfits[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: SizedBox(
                              width: 56,
                              height: 56,
                              child: Image.network(outfit.imageUrl, fit: BoxFit.cover),
                            ),
                            title: Text(outfit.title),
                            subtitle: Text('Стили: ${outfit.styles.join(", ")}'),
                          ),
                        );
                      },
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
