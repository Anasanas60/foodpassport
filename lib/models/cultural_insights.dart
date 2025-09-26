class CulturalInsights {
  final String dishName;
  final String origin;
  final String culturalSignificance;
  final String historicalBackground;
  final List<String> traditionalOccasions;
  final List<String> preparationMethods;
  final Map<String, String> regionalVariations;
  final String culturalEtiquette;
  final String source;

  CulturalInsights({
    required this.dishName,
    required this.origin,
    required this.culturalSignificance,
    required this.historicalBackground,
    required this.traditionalOccasions,
    required this.preparationMethods,
    required this.regionalVariations,
    required this.culturalEtiquette,
    required this.source,
  });

  factory CulturalInsights.fromMap(Map<String, dynamic> map) {
    return CulturalInsights(
      dishName: map['dishName'] ?? '',
      origin: map['origin'] ?? 'International',
      culturalSignificance: map['culturalSignificance'] ?? '',
      historicalBackground: map['historicalBackground'] ?? '',
      traditionalOccasions: List<String>.from(map['traditionalOccasions'] ?? []),
      preparationMethods: List<String>.from(map['preparationMethods'] ?? []),
      regionalVariations: Map<String, String>.from(map['regionalVariations'] ?? {}),
      culturalEtiquette: map['culturalEtiquette'] ?? '',
      source: map['source'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dishName': dishName,
      'origin': origin,
      'culturalSignificance': culturalSignificance,
      'historicalBackground': historicalBackground,
      'traditionalOccasions': traditionalOccasions,
      'preparationMethods': preparationMethods,
      'regionalVariations': regionalVariations,
      'culturalEtiquette': culturalEtiquette,
      'source': source,
    };
  }
}
