class Post {
  final String id;
  final String farmerId;
  final String farmerName;
  final String title;
  final String content;
  final String? photoUrl;
  final String? cropTag;
  final String? problemTag;
  final int likes;
  final int commentsCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.title,
    required this.content,
    this.photoUrl,
    this.cropTag,
    this.problemTag,
    required this.likes,
    required this.commentsCount,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: json['farmerName'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      photoUrl: json['photoUrl'] as String?,
      cropTag: json['cropTag'] as String?,
      problemTag: json['problemTag'] as String?,
      likes: json['likes'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'title': title,
      'content': content,
      'photoUrl': photoUrl,
      'cropTag': cropTag,
      'problemTag': problemTag,
      'likes': likes,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
