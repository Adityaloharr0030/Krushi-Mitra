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
  final String applyLink;
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
    required this.applyLink,
    required this.helplineNumber,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    DateTime parsedDeadline;
    final deadlineVal = json['deadline'];
    if (deadlineVal is String) {
      final parsed = DateTime.tryParse(deadlineVal);
      if (parsed != null) {
        parsedDeadline = parsed;
      } else {
        parsedDeadline = DateTime.now().add(const Duration(days: 365));
      }
    } else if (deadlineVal is int) {
      parsedDeadline = DateTime.fromMillisecondsSinceEpoch(deadlineVal);
    } else {
      parsedDeadline = DateTime.now().add(const Duration(days: 30));
    }

    return Scheme(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ministryLogo: (json['ministryLogo'] ?? '').toString(),
      deadline: parsedDeadline,
      benefitAmount: (json['benefitAmount'] ?? '').toString(),
      eligibilityCriteria: List<String>.from(json['eligibilityCriteria'] ?? []),
      requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
      howToApply: (json['howToApply'] ?? '').toString(),
      websiteLink: (json['websiteLink'] ?? '').toString(),
      applyLink: (json['applyLink'] ?? json['websiteLink'] ?? '').toString(),
      helplineNumber: (json['helplineNumber'] ?? '').toString(),
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
      'applyLink': applyLink,
      'helplineNumber': helplineNumber,
    };
  }
}
