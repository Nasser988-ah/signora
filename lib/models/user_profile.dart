class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String userType; // 'student' or 'professor'
  final String? avatarUrl;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.userType,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      userType: json['user_type'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'user_type': userType,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isProfessor => userType == 'professor';
  bool get isStudent => userType == 'student';
}
