class UserProfile {
  final String? id;
  final String? name;
  final int? age;
  final List<String> allergies;
  final String? dietaryPreference;
  final String? country;
  final String? language;

  UserProfile({
    this.id,
    this.name,
    this.age,
    this.allergies = const [],
    this.dietaryPreference,
    this.country,
    this.language,
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'allergies': allergies,
      'dietary_preference': dietaryPreference,
      'country': country,
      'language': language,
    };
  }

  // Create from map (from storage)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      allergies: List<String>.from(map['allergies'] ?? []),
      dietaryPreference: map['dietary_preference'],
      country: map['country'],
      language: map['language'],
    );
  }

  // Copy with method for updates
  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    List<String>? allergies,
    String? dietaryPreference,
    String? country,
    String? language,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      allergies: allergies ?? this.allergies,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      country: country ?? this.country,
      language: language ?? this.language,
    );
  }
}
