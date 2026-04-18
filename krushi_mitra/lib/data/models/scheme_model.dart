class Scheme {
  final String id;
  final String name;
  final String description;
  final String ministryLogo;
  final DateTime deadline;
  final String benefitAmount;
  final List<String> eligibilityCriteria;
  final List<String> requiredDocuments;
  final String howToApply;
  final String websiteLink;
  final String helplineNumber;

  Scheme({
    required this.id,
    required this.name,
    required this.description,
    required this.ministryLogo,
    required this.deadline,
    required this.benefitAmount,
    required this.eligibilityCriteria,
    required this.requiredDocuments,
    required this.howToApply,
    required this.websiteLink,
    required this.helplineNumber,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ministryLogo: json['ministryLogo'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      benefitAmount: json['benefitAmount'] as String,
      eligibilityCriteria: List<String>.from(json['eligibilityCriteria'] ?? []),
      requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
      howToApply: json['howToApply'] as String,
      websiteLink: json['websiteLink'] as String,
      helplineNumber: json['helplineNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ministryLogo': ministryLogo,
      'deadline': deadline.toIso8601String(),
      'benefitAmount': benefitAmount,
      'eligibilityCriteria': eligibilityCriteria,
      'requiredDocuments': requiredDocuments,
      'howToApply': howToApply,
      'websiteLink': websiteLink,
      'helplineNumber': helplineNumber,
    };
  }
}
