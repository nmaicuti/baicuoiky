class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String? avatar;
  final String role; // Thêm role
  final DateTime createdAt;
  final DateTime lastActive;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.avatar,
    required this.role, // Thêm role
    required this.createdAt,
    required this.lastActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      role: json['role'] as String, // Thêm role
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'avatar': avatar,
      'role': role, // Thêm role
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }
}