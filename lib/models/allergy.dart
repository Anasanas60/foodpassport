enum AllergySeverity {
  mild('mild'),
  moderate('moderate'),
  severe('severe');

  final String value;
  const AllergySeverity(this.value);

  static AllergySeverity fromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return AllergySeverity.mild;
      case 'moderate':
        return AllergySeverity.moderate;
      case 'severe':
        return AllergySeverity.severe;
      default:
        return AllergySeverity.moderate;
    }
  }
}

class Allergy {
  final String id;
  final String name;
  final String category;
  final String description;
  final AllergySeverity severity;
  final bool isCommon;

  Allergy({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.severity,
    required this.isCommon,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'other',
      description: json['description'] ?? '',
      severity: AllergySeverity.fromString(json['severity'] ?? 'moderate'),
      isCommon: json['isCommon'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'severity': severity.value,
      'isCommon': isCommon,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Allergy && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
