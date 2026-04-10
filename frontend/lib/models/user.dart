class User {
  final String id;
  final String username;
  final String fullName;
  final String role;
  final String? branchId;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.branchId,
  });

  factory User.fromJwtPayload(Map<String, dynamic> payload) {
    return User(
      id: payload['sub'] as String,
      username: payload['username'] as String,
      fullName: payload['username'] as String,
      role: payload['role'] as String,
    );
  }
}
