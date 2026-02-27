import 'user_model.dart';

class Post {
  final int? id;
  final User? user; // Backend sends 'user' object
  final String? caption;
  final String mediaUrl;
  final DateTime? createdAt;
  final int likeCount;
  final int commentCount;

  Post({
    this.id,
    this.user,
    this.caption,
    required this.mediaUrl,
    this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      caption: json['caption'],
      mediaUrl: json['mediaUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
    );
  }
}
