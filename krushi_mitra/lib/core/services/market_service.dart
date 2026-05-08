import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../data/models/market_price_model.dart';

class MarketService {
  static final MarketService _instance = MarketService._internal();
  factory MarketService() => _instance;
  MarketService._internal();

  late final Dio _dio;
  static const String _cacheKey = 'cached_market_data';

  void initialize() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ));
  }

  Future<List<MarketPrice>> getMarketPrices({
    String? state,
    String? district,
    String? commodity,
    bool forceRefresh = false,
  }) async {
    final apiKey = dotenv.env['AGMARKET_KEY'] ?? '';
    
    // 1. Load Cache (if not forcing refresh)
    final List<MarketPrice> cached = forceRefresh ? [] : await _getCachedMarket();

    if (apiKey.isEmpty) {
      if (cached.isNotEmpty) return cached;
      return await _getOfflineMarketData(state: state, commodity: commodity);
    }

    try {
      const String resourceId = ApiConstants.agmarknetResource;
      final Map<String, dynamic> params = {
        'api-key': apiKey,
        'format': 'json',
        'limit': 500,
      };

      if (state != null && state.isNotEmpty) params['filters[state]'] = state;
      if (district != null && district.isNotEmpty) params['filters[district]'] = district;
      if (commodity != null && commodity.isNotEmpty) params['filters[commodity]'] = commodity;

      final response = await _dio.get(
        'https://api.data.gov.in/resource/$resourceId',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final List records = response.data['records'] ?? [];
        if (records.isEmpty) {
          if (cached.isNotEmpty) return cached;
          return await _getOfflineMarketData(state: state, commodity: commodity);
        }
        final result = records.map((r) => MarketPrice.fromJson(r)).toList();
        _cacheMarket(result);
        return result;
      }
      
      if (cached.isNotEmpty) return cached;
      return await _getOfflineMarketData(state: state, commodity: commodity);
    } catch (e) {
      debugPrint('Market API Error: $e. Using cache or offline data.');
      if (cached.isNotEmpty) return cached;
      return await _getOfflineMarketData(state: state, commodity: commodity);
    }
  }

  Future<void> _cacheMarket(List<MarketPrice> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = data.map((e) => e.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(jsonList));
    } catch (_) {}
  }

  Future<List<MarketPrice>> _getCachedMarket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr != null) {
        final List list = json.decode(jsonStr);
        return list.map((e) => MarketPrice.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Comprehensive offline fallback data with realistic MSP-aligned prices
  Future<List<MarketPrice>> _getOfflineMarketData({String? state, String? commodity}) async {
    final today = DateTime.now();
    final dateStr = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    final yesterdayStr = '${(today.day - 1).toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    final resolvedState = state ?? 'Maharashtra';

    // Full set of realistic offline data (MSP-based for Kharif/Rabi 2025-26)
    final allPrices = <MarketPrice>[
      MarketPrice(commodity: 'Wheat', variety: 'Lokwan', state: resolvedState, district: 'Nashik', market: 'Lasalgaon', minPrice: 2275, maxPrice: 2700, modalPrice: 2500, date: dateStr),
      MarketPrice(commodity: 'Wheat', variety: 'Sharbati', state: resolvedState, district: 'Pune', market: 'Pune', minPrice: 2400, maxPrice: 2850, modalPrice: 2650, date: dateStr),
      MarketPrice(commodity: 'Onion', variety: 'Red', state: resolvedState, district: 'Nashik', market: 'Pimpalgaon', minPrice: 800, maxPrice: 1600, modalPrice: 1200, date: dateStr),
      MarketPrice(commodity: 'Onion', variety: 'White', state: resolvedState, district: 'Nashik', market: 'Lasalgaon', minPrice: 900, maxPrice: 1800, modalPrice: 1350, date: yesterdayStr),
      MarketPrice(commodity: 'Tomato', variety: 'Hybrid', state: resolvedState, district: 'Pune', market: 'Pune', minPrice: 1000, maxPrice: 2200, modalPrice: 1600, date: dateStr),
      MarketPrice(commodity: 'Tomato', variety: 'Local', state: resolvedState, district: 'Satara', market: 'Satara', minPrice: 800, maxPrice: 1800, modalPrice: 1300, date: yesterdayStr),
      MarketPrice(commodity: 'Cotton', variety: 'Medium Staple', state: resolvedState, district: 'Amravati', market: 'Amravati', minPrice: 6620, maxPrice: 7500, modalPrice: 7080, date: dateStr),
      MarketPrice(commodity: 'Soyabean', variety: 'Yellow', state: resolvedState, district: 'Latur', market: 'Latur', minPrice: 4200, maxPrice: 4800, modalPrice: 4550, date: dateStr),
      MarketPrice(commodity: 'Rice', variety: 'Basmati', state: resolvedState, district: 'Kolhapur', market: 'Kolhapur', minPrice: 3800, maxPrice: 4500, modalPrice: 4150, date: dateStr),
      MarketPrice(commodity: 'Gram', variety: 'Desi', state: resolvedState, district: 'Latur', market: 'Latur', minPrice: 5230, maxPrice: 5800, modalPrice: 5500, date: yesterdayStr),
      MarketPrice(commodity: 'Maize', variety: 'Yellow', state: resolvedState, district: 'Aurangabad', market: 'Aurangabad', minPrice: 1962, maxPrice: 2300, modalPrice: 2120, date: dateStr),
      MarketPrice(commodity: 'Potato', variety: 'Jyoti', state: resolvedState, district: 'Pune', market: 'Pune', minPrice: 1200, maxPrice: 1800, modalPrice: 1500, date: dateStr),
      MarketPrice(commodity: 'Jowar', variety: 'Maldandi', state: resolvedState, district: 'Solapur', market: 'Solapur', minPrice: 3180, maxPrice: 3600, modalPrice: 3400, date: dateStr),
    ];

    // Filter by commodity if specified
    if (commodity != null && commodity.isNotEmpty) {
      final filtered = allPrices.where((p) => p.commodity.toLowerCase() == commodity.toLowerCase()).toList();
      return filtered.isNotEmpty ? filtered : allPrices.take(5).toList();
    }

    return allPrices;
  }

  /// Commodity-specific price trend data (simulates 7-day history)
  List<double> getPriceTrend(String commodity) {
    final trends = <String, List<double>>{
      'Wheat':    [2420, 2450, 2480, 2465, 2500, 2510, 2500],
      'Onion':    [1350, 1280, 1200, 1150, 1180, 1220, 1200],
      'Tomato':   [1200, 1350, 1500, 1580, 1620, 1550, 1600],
      'Cotton':   [6950, 7000, 7050, 7020, 7080, 7100, 7080],
      'Soyabean': [4300, 4350, 4400, 4450, 4500, 4520, 4550],
      'Rice':     [3950, 4000, 4050, 4080, 4100, 4120, 4150],
      'Gram':     [5350, 5400, 5420, 5450, 5480, 5500, 5500],
      'Maize':    [2000, 2020, 2050, 2080, 2100, 2110, 2120],
      'Potato':   [1600, 1550, 1520, 1500, 1480, 1500, 1500],
      'Jowar':    [3200, 3250, 3300, 3350, 3380, 3400, 3400],
    };
    return trends[commodity] ?? [2200, 2230, 2260, 2280, 2300, 2310, 2300];
  }

  List<String> getAvailableStates() {
    return [
      'Maharashtra', 'Uttar Pradesh', 'Madhya Pradesh', 'Punjab', 'Rajasthan',
      'Gujarat', 'Karnataka', 'Andhra Pradesh', 'Tamil Nadu', 'Haryana',
    ];
  }

  List<String> getDistrictsByState(String state) {
    final Map<String, List<String>> districts = {
      'Maharashtra': ['Pune', 'Nashik', 'Aurangabad', 'Latur', 'Amravati', 'Nagpur', 'Kolhapur', 'Satara', 'Solapur'],
      'Uttar Pradesh': ['Lucknow', 'Agra', 'Varanasi', 'Kanpur', 'Meerut', 'Allahabad'],
      'Punjab': ['Amritsar', 'Ludhiana', 'Patiala', 'Jalandhar', 'Bathinda'],
      'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Ujjain', 'Sagar'],
    };
    return districts[state] ?? ['All Districts'];
  }
}
