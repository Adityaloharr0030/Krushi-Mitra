import 'package:dio/dio.dart';

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
}

class MarketService {
  static final MarketService _instance = MarketService._internal();
  factory MarketService() => _instance;
  MarketService._internal();

  late final Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  Future<List<MarketPrice>> getMarketPrices({
    String? state,
    String? district,
    String? commodity,
  }) async {
    // Return mock data since Agmarknet API requires registration
    return _getMockMarketData(state: state, commodity: commodity);
  }

  List<MarketPrice> _getMockMarketData({String? state, String? commodity}) {
    final prices = [
      MarketPrice(
        commodity: 'Wheat',
        variety: 'Lokwan',
        state: state ?? 'Maharashtra',
        district: 'Pune',
        market: 'Pune Mandi',
        minPrice: 2100,
        maxPrice: 2450,
        modalPrice: 2320,
        date: '17-04-2026',
      ),
      MarketPrice(
        commodity: 'Rice',
        variety: 'Basmati',
        state: state ?? 'Maharashtra',
        district: 'Pune',
        market: 'Pune Mandi',
        minPrice: 3200,
        maxPrice: 4100,
        modalPrice: 3650,
        date: '17-04-2026',
      ),
      MarketPrice(
        commodity: 'Onion',
        variety: 'Red',
        state: state ?? 'Maharashtra',
        district: 'Nashik',
        market: 'Lasalgaon Mandi',
        minPrice: 800,
        maxPrice: 1400,
        modalPrice: 1100,
        date: '17-04-2026',
      ),
      MarketPrice(
        commodity: 'Soybean',
        variety: 'Yellow',
        state: state ?? 'Maharashtra',
        district: 'Latur',
        market: 'Latur Mandi',
        minPrice: 4200,
        maxPrice: 5100,
        modalPrice: 4700,
        date: '17-04-2026',
      ),
      MarketPrice(
        commodity: 'Cotton',
        variety: 'Long Staple',
        state: state ?? 'Maharashtra',
        district: 'Amravati',
        market: 'Amravati Mandi',
        minPrice: 6800,
        maxPrice: 7500,
        modalPrice: 7200,
        date: '17-04-2026',
      ),
      MarketPrice(
        commodity: 'Sugarcane',
        variety: 'CO-86032',
        state: state ?? 'Maharashtra',
        district: 'Kolhapur',
        market: 'Kolhapur Mandi',
        minPrice: 3200,
        maxPrice: 3500,
        modalPrice: 3380,
        date: '17-04-2026',
      ),
      MarketPrice(
        commodity: 'Tomato',
        variety: 'Hybrid',
        state: state ?? 'Maharashtra',
        district: 'Nashik',
        market: 'Pimpalgaon Mandi',
        minPrice: 600,
        maxPrice: 1800,
        modalPrice: 1200,
        date: '17-04-2026',
      ),
      MarketPrice(
        commodity: 'Potato',
        variety: 'Kufri Jyoti',
        state: state ?? 'Maharashtra',
        district: 'Satara',
        market: 'Satara Mandi',
        minPrice: 900,
        maxPrice: 1400,
        modalPrice: 1150,
        date: '17-04-2026',
      ),
    ];

    if (commodity != null && commodity.isNotEmpty) {
      return prices
          .where((p) => p.commodity.toLowerCase().contains(commodity.toLowerCase()))
          .toList();
    }
    return prices;
  }

  /// Get 7-day price trend data for a commodity (mock)
  List<double> getPriceTrend(String commodity) {
    final Map<String, List<double>> trends = {
      'Wheat': [2250, 2280, 2300, 2290, 2310, 2320, 2320],
      'Rice': [3450, 3500, 3600, 3580, 3620, 3640, 3650],
      'Onion': [900, 980, 1050, 1020, 1100, 1080, 1100],
      'Soybean': [4500, 4550, 4620, 4680, 4700, 4720, 4700],
      'Cotton': [7000, 7050, 7100, 7150, 7200, 7180, 7200],
      'Tomato': [800, 1000, 1200, 1350, 1250, 1180, 1200],
    };
    return trends[commodity] ?? [1000, 1050, 1000, 1100, 1150, 1100, 1150];
  }

  List<String> getAvailableStates() {
    return [
      'Maharashtra',
      'Uttar Pradesh',
      'Madhya Pradesh',
      'Punjab',
      'Rajasthan',
      'Gujarat',
      'Karnataka',
      'Andhra Pradesh',
      'Tamil Nadu',
      'Haryana',
    ];
  }

  List<String> getDistrictsByState(String state) {
    final Map<String, List<String>> districts = {
      'Maharashtra': ['Pune', 'Nashik', 'Aurangabad', 'Latur', 'Amravati', 'Nagpur', 'Kolhapur', 'Satara', 'Solapur'],
      'Uttar Pradesh': ['Lucknow', 'Agra', 'Varanasi', 'Kanpur', 'Meerut', 'Allahabad'],
      'Punjab': ['Amritsar', 'Ludhiana', 'Patiala', 'Jalandhar', 'Bathinda'],
      'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Ujjain', 'Sagar'],
    };
    return districts[state] ?? ['District 1', 'District 2', 'District 3'];
  }
}
