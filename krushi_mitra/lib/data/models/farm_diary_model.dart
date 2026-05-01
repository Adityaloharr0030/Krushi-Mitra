import 'package:equatable/equatable.dart';

class FarmDiaryEntry extends Equatable {
  final String id;
  final String farmerId;
  final DateTime date;
  final String activity;
  final String category;
  final double cost;
  final bool isExpense;
  final String? notes;

  const FarmDiaryEntry({
    required this.id,
    required this.farmerId,
    required this.date,
    required this.activity,
    required this.category,
    required this.cost,
    required this.isExpense,
    this.notes,
  });

  factory FarmDiaryEntry.fromJson(Map<String, dynamic> json) {
    return FarmDiaryEntry(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      date: (json['date'] as dynamic)?.toDate() ?? DateTime.now(),
      activity: json['activity'] ?? '',
      category: json['category'] ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      isExpense: json['isExpense'] ?? true,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'date': date,
      'activity': activity,
      'category': category,
      'cost': cost,
      'isExpense': isExpense,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [id, farmerId, date, activity, category, cost, isExpense, notes];
}
