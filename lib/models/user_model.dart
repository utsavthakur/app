class User {
  final int? id;
  final String username;
  final String email;
  final String? bio;
  final String? profilePicture;
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.bio,
    this.profilePicture,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      profilePicture: json['profilePicture'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'profilePicture': profilePicture,
      // 'createdAt' is usually read-only from client perspective
    };
  }
}
