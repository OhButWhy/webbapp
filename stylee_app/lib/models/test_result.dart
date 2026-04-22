class TestResult {
  final double? height;
  final double? bust;
  final double? waist;
  final double? hips;
  final String? city;
  final List<String>? preferredStyles;
  final List<String>? favoriteColors;
  final List<String>? avoidedColors;
  final String? fitPreference; // свободная / средняя / облегающая
  final String? specialNotes;

  TestResult({
    this.height,
    this.bust,
    this.waist,
    this.hips,
    this.city,
    this.preferredStyles,
    this.favoriteColors,
    this.avoidedColors,
    this.fitPreference,
    this.specialNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'bust': bust,
      'waist': waist,
      'hips': hips,
      'city': city,
      'preferredStyles': preferredStyles,
      'favoriteColors': favoriteColors,
      'avoidedColors': avoidedColors,
      'fitPreference': fitPreference,
      'specialNotes': specialNotes,
    };
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      height: (map['height'] ?? 0).toDouble(),
      bust: (map['bust'] ?? 0).toDouble(),
      waist: (map['waist'] ?? 0).toDouble(),
      hips: (map['hips'] ?? 0).toDouble(),
      city: map['city'],
      preferredStyles: map['preferredStyles'] != null ? List<String>.from(map['preferredStyles']) : null,
      favoriteColors: map['favoriteColors'] != null ? List<String>.from(map['favoriteColors']) : null,
      avoidedColors: map['avoidedColors'] != null ? List<String>.from(map['avoidedColors']) : null,
      fitPreference: map['fitPreference'],
      specialNotes: map['specialNotes'],
    );
  }
}
