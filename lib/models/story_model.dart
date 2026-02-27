import 'user_model.dart';

enum MediaType { IMAGE, VIDEO }

class Story {
  final int? id;
  final User? user;
  final String mediaUrl;
  final MediaType mediaType;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  Story({
    this.id,
    this.user,
    required this.mediaUrl,
    required this.mediaType,
    this.expiresAt,
    this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      mediaUrl: json['mediaUrl'],
      mediaType: _parseMediaType(json['mediaType']),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  static MediaType _parseMediaType(String? type) {
    if (type == 'VIDEO') return MediaType.VIDEO;
    return MediaType.IMAGE;
  }
}
