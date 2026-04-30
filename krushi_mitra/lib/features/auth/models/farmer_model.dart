import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class FarmerModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final String village;
  final String district;
  final String state;
  final List<String> crops;
  final double landAcres;
  final String language; // 'en', 'hi', 'mr'
  final DateTime createdAt;
  final DateTime? lastActive;

  const FarmerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.village,
    required this.district,
    required this.state,
    required this.crops,
    required this.landAcres,
    required this.language,
    required this.createdAt,
    this.lastActive,
  });

  factory FarmerModel.empty() => FarmerModel(
        id: '',
        name: '',
        phone: '',
        village: '',
        district: '',
        state: 'Maharashtra',
        crops: const [],
        landAcres: 0,
        language: 'hi',
        createdAt: DateTime.now(),
      );

  factory FarmerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmerModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      village: data['village'] ?? '',
      district: data['district'] ?? '',
      state: data['state'] ?? 'Maharashtra',
      crops: List<String>.from(data['crops'] ?? []),
      landAcres: (data['landAcres'] as num?)?.toDouble() ?? 0,
      language: data['language'] ?? 'hi',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'village': village,
      'district': district,
      'state': state,
      'crops': crops,
      'landAcres': landAcres,
      'language': language,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': FieldValue.serverTimestamp(),
    };
  }

  FarmerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? photoUrl,
    String? village,
    String? district,
    String? state,
    List<String>? crops,
    double? landAcres,
    String? language,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return FarmerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      crops: crops ?? this.crops,
      landAcres: landAcres ?? this.landAcres,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  String get cropsList => crops.join(', ');
  String get initials =>
      name.isNotEmpty ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase() : 'FM';

  @override
  List<Object?> get props => [id, name, phone, district, state, crops, landAcres, language];
}
