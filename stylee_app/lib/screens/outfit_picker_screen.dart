import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stylee_app/services/backend_api_service.dart';
import '../models/outfit.dart';
import '../models/outfit_list.dart';

class OutfitPickerScreen extends StatefulWidget {
  const OutfitPickerScreen({super.key});

  @override
  State<OutfitPickerScreen> createState() => _OutfitPickerScreenState();
}

class _OutfitPickerScreenState extends State<OutfitPickerScreen> {
  final _backend = BackendApiService.instance;
  List<String> favoriteImages = [];
  bool loadingFavorites = true;
    @override
    void initState() {
      super.initState();
      _loadFavorites();
    }

    Future<void> _loadFavorites() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          loadingFavorites = false;
        });
        return;
      }
      final favorites = await _backend.getFavorites(user.email!);
      setState(() {
        favoriteImages = favorites;
        loadingFavorites = false;
      });
    }

    Future<void> _toggleFavorite(String imageUrl) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final isFavorite = favoriteImages.contains(imageUrl);
      setState(() {
        if (isFavorite) {
          favoriteImages.remove(imageUrl);
        } else {
          favoriteImages.add(imageUrl);
        }
      });

      if (isFavorite) {
        await _backend.removeFavorite(user.email!, imageUrl);
      } else {
        await _backend.addFavorite(user.email!, imageUrl);
      }
    }
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
              loadingFavorites
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: filteredOutfits.isEmpty
                          ? const Center(child: Text('Нет подходящих образов'))
                          : ListView.builder(
                              itemCount: filteredOutfits.length,
                              itemBuilder: (context, idx) {
                                final outfit = filteredOutfits[idx];
                                final isFavorite = favoriteImages.contains(outfit.imageUrl);
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
                                    trailing: IconButton(
                                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : null),
                                      tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
                                      onPressed: () => _toggleFavorite(outfit.imageUrl),
                                    ),
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
