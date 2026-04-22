class Outfit {
  final String id;
  final String title;
  final String imageUrl;
  final List<String> events; // мероприятия: работа, вечеринка, прогулка и т.д.
  final List<String> weathers; // погода: жарко, прохладно, дождь
  final List<String> colors; // основные цвета
  final List<String> styles; // стили: кэжуал, классика и т.д.

  Outfit({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.events,
    required this.weathers,
    required this.colors,
    required this.styles,
  });
}
