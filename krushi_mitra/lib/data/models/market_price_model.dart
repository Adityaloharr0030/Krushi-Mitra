class MarketPrice {
  final String commodity;
  final String variety;
  final String state;
  final String district;
  final String market;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String date;

  MarketPrice({
    required this.commodity,
    required this.variety,
    required this.state,
    required this.district,
    required this.market,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.date,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      commodity: json['commodity'] ?? json['Commodity'] ?? '',
      variety: json['variety'] ?? json['Variety'] ?? '',
      state: json['state'] ?? json['State'] ?? '',
      district: json['district'] ?? json['District'] ?? '',
      market: json['market'] ?? json['Market'] ?? '',
      minPrice: double.tryParse(json['min_price']?.toString() ??
              json['Min Price']?.toString() ?? '0') ??
          0,
      maxPrice: double.tryParse(json['max_price']?.toString() ??
              json['Max Price']?.toString() ?? '0') ??
          0,
      modalPrice: double.tryParse(json['modal_price']?.toString() ??
              json['Modal Price']?.toString() ?? '0') ??
          0,
      date: json['arrival_date'] ?? json['Arrival Date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'commodity': commodity,
    'variety': variety,
    'state': state,
    'district': district,
    'market': market,
    'min_price': minPrice,
    'max_price': maxPrice,
    'modal_price': modalPrice,
    'arrival_date': date,
  };
}
