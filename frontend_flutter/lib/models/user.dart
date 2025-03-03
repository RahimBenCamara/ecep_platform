class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final bool isActive;
  final int? parentId;

  User({required this.id, required this.username, required this.email, required this.role, required this.isActive, this.parentId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      isActive: json['is_active'],
      parentId: json['parent'],
    );
  }
}