import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceListing {
  final String id;
  final String sellerId;
  final String farmerName;
  final String commodity;
  final double quantity;
  final String unit; // kg, quintal, ton
  final double pricePerUnit;
  final String quality; // A+, A, B
  final String location;
  final String description;
  final String imageUrl;
  final String? phoneNumber;
  final DateTime dateListed;
  final bool isVerified;
  final bool isSold;

  MarketplaceListing({
    required this.id,
    required this.sellerId,
    required this.farmerName,
    required this.commodity,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.quality,
    required this.location,
    required this.description,
    required this.imageUrl,
    this.phoneNumber,
    required this.dateListed,
    this.isVerified = false,
    this.isSold = false,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    return MarketplaceListing(
      id: json['id'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      farmerName: json['farmerName'] as String? ?? 'Unknown Farmer',
      commodity: json['commodity'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'Quintal',
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0,
      quality: json['quality'] as String? ?? 'B',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      dateListed: json['dateListed'] is Timestamp
          ? (json['dateListed'] as Timestamp).toDate()
          : DateTime.tryParse(json['dateListed']?.toString() ?? '') ?? DateTime.now(),
      isVerified: json['isVerified'] as bool? ?? false,
      isSold: json['isSold'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'farmerName': farmerName,
      'commodity': commodity,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'quality': quality,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'dateListed': Timestamp.fromDate(dateListed),
      'isVerified': isVerified,
      'isSold': isSold,
    };
  }

  /// Get an emoji icon based on commodity name
  String get cropEmoji {
    final name = commodity.toLowerCase();
    if (name.contains('wheat') || name.contains('गेहूं')) return '🌾';
    if (name.contains('rice') || name.contains('चावल') || name.contains('paddy')) return '🍚';
    if (name.contains('onion') || name.contains('प्याज')) return '🧅';
    if (name.contains('tomato') || name.contains('टमाटर')) return '🍅';
    if (name.contains('potato') || name.contains('आलू')) return '🥔';
    if (name.contains('corn') || name.contains('maize') || name.contains('मक्का')) return '🌽';
    if (name.contains('cotton') || name.contains('कपास')) return '🏵️';
    if (name.contains('sugarcane') || name.contains('गन्ना')) return '🎋';
    if (name.contains('soybean') || name.contains('soya')) return '🫘';
    if (name.contains('chilli') || name.contains('mirchi') || name.contains('pepper')) return '🌶️';
    if (name.contains('banana') || name.contains('केला')) return '🍌';
    if (name.contains('mango') || name.contains('आम')) return '🥭';
    if (name.contains('apple') || name.contains('सेब')) return '🍎';
    if (name.contains('grape') || name.contains('अंगूर')) return '🍇';
    if (name.contains('orange') || name.contains('संतरा')) return '🍊';
    if (name.contains('lemon') || name.contains('नींबू')) return '🍋';
    if (name.contains('carrot') || name.contains('गाजर')) return '🥕';
    if (name.contains('cabbage') || name.contains('पत्ता')) return '🥬';
    if (name.contains('garlic') || name.contains('लहसुन')) return '🧄';
    if (name.contains('pea') || name.contains('मटर')) return '🫛';
    if (name.contains('milk') || name.contains('दूध')) return '🥛';
    return '🌿';
  }

  /// Get a display-friendly time ago string
  String get timeAgo {
    final diff = DateTime.now().difference(dateListed);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
