class Farmer {
  final String id;
  final String name;
  final String? photoUrl;
  final String state;
  final String district;
  final double landSize;
  final List<String> cropsGrown;
  final String preferredLanguage;
  final String? soilType;
  final String? irrigationSource;

  Farmer({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.state,
    required this.district,
    required this.landSize,
    required this.cropsGrown,
    required this.preferredLanguage,
    this.soilType,
    this.irrigationSource,
    this.weatherAlerts = true,
    this.schemeAlerts = true,
    this.priceAlerts = false,
  });

  final bool weatherAlerts;
  final bool schemeAlerts;
  final bool priceAlerts;

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
      soilType: json['soilType'] as String?,
      irrigationSource: json['irrigationSource'] as String?,
      weatherAlerts: json['weatherAlerts'] as bool? ?? true,
      schemeAlerts: json['schemeAlerts'] as bool? ?? true,
      priceAlerts: json['priceAlerts'] as bool? ?? false,
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
      'soilType': soilType,
      'irrigationSource': irrigationSource,
      'weatherAlerts': weatherAlerts,
      'schemeAlerts': schemeAlerts,
      'priceAlerts': priceAlerts,
    };
  }

  Farmer copyWith({
    String? id,
    String? name,
    String? photoUrl,
    String? state,
    String? district,
    double? landSize,
    List<String>? cropsGrown,
    String? preferredLanguage,
    String? soilType,
    String? irrigationSource,
    bool? weatherAlerts,
    bool? schemeAlerts,
    bool? priceAlerts,
  }) {
    return Farmer(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      state: state ?? this.state,
      district: district ?? this.district,
      landSize: landSize ?? this.landSize,
      cropsGrown: cropsGrown ?? this.cropsGrown,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      soilType: soilType ?? this.soilType,
      irrigationSource: irrigationSource ?? this.irrigationSource,
      weatherAlerts: weatherAlerts ?? this.weatherAlerts,
      schemeAlerts: schemeAlerts ?? this.schemeAlerts,
      priceAlerts: priceAlerts ?? this.priceAlerts,
    );
  }
}
