class SchemeModel {
  final String id;
  final String name;
  final String nameHindi;
  final String description;
  final String benefit;
  final String eligibility;
  final List<String> documentsRequired;
  final String applyUrl;
  final String category;
  final bool isActive;

  SchemeModel({
    required this.id,
    required this.name,
    required this.nameHindi,
    required this.description,
    required this.benefit,
    required this.eligibility,
    required this.documentsRequired,
    required this.applyUrl,
    required this.category,
    required this.isActive,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameHindi: json['nameHindi'] ?? '',
      description: json['description'] ?? '',
      benefit: json['benefit'] ?? '',
      eligibility: json['eligibility'] ?? '',
      documentsRequired: List<String>.from(json['documentsRequired'] ?? []),
      applyUrl: json['applyUrl'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}
