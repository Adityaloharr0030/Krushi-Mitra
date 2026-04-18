class MandiPrice {
  final String id;
  final String state;
  final String district;
  final String commodity;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final DateTime date;

  MandiPrice({
    required this.id,
    required this.state,
    required this.district,
    required this.commodity,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.date,
  });

  factory MandiPrice.fromJson(Map<String, dynamic> json) {
    return MandiPrice(
      id: json['id'] as String,
      state: json['state'] as String,
      district: json['district'] as String,
      commodity: json['commodity'] as String,
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      modalPrice: (json['modalPrice'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'district': district,
      'commodity': commodity,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'modalPrice': modalPrice,
      'date': date.toIso8601String(),
    };
  }
}
