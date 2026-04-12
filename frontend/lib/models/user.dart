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
    final fullName =
        payload['full_name']?.toString() ??
        payload['fullName']?.toString() ??
        payload['name']?.toString() ??
        payload['username']?.toString();

    return User(
      id: payload['sub'] as String,
      username: payload['username'] as String,
      fullName: fullName ?? payload['username'] as String,
      role: payload['role'] as String,
      branchId:
          payload['branch_id']?.toString() ?? payload['branchId']?.toString(),
    );
  }
}
