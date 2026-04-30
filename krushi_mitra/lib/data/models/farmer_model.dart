class Farmer {
  final String id;
  final String name;
  final String? photoUrl;
  final String state;
  final String district;
  final double landSize;
  final List<String> cropsGrown;
  final String preferredLanguage;

  Farmer({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.state,
    required this.district,
    required this.landSize,
    required this.cropsGrown,
    required this.preferredLanguage,
  });

  // Firebase User-like compatibility getters
  String? get displayName => name;
  bool get isAnonymous => id.isEmpty || name == 'Guest';
  String? get email => null;

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      state: json['state'] as String,
      district: json['district'] as String,
      landSize: (json['landSize'] as num).toDouble(),
      cropsGrown: List<String>.from(json['cropsGrown'] ?? []),
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'state': state,
      'district': district,
      'landSize': landSize,
      'cropsGrown': cropsGrown,
      'preferredLanguage': preferredLanguage,
    };
  }
}
