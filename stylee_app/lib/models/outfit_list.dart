import 'outfit.dart';

/// Статичный список образов для MVP подбора
final List<Outfit> outfits = [
  Outfit(
    id: '1',
    title: 'Классика на работу',
    imageUrl: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f',
    events: ['работа'],
    weathers: ['прохладно', 'жарко'],
    colors: ['чёрный', 'белый'],
    styles: ['классика'],
  ),
  Outfit(
    id: '2',
    title: 'Летний кэжуал',
    imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    events: ['прогулка', 'вечеринка'],
    weathers: ['жарко'],
    colors: ['белый', 'голубой'],
    styles: ['кэжуал'],
  ),
  Outfit(
    id: '3',
    title: 'Вечерний образ',
    imageUrl: 'https://images.unsplash.com/photo-1469398715555-76331e2c5e43',
    events: ['вечеринка'],
    weathers: ['прохладно'],
    colors: ['красный', 'чёрный'],
    styles: ['элегантный'],
  ),
  Outfit(
    id: '4',
    title: 'Дождливая прогулка',
    imageUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
    events: ['прогулка'],
    weathers: ['дождь'],
    colors: ['синий', 'серый'],
    styles: ['спорт-шик'],
  ),
];
