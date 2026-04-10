import 'dart:convert';

import '../../models/user.dart';

const _sessionVersion = 1;
const _jwtExpiryLeeway = Duration(seconds: 30);

class AuthSession {
  final String token;
  final User user;

  const AuthSession({required this.token, required this.user});

  Map<String, dynamic> toJson() {
    return {
      'version': _sessionVersion,
      'token': token,
      'user': userToJson(user),
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final userJson = json['user'];

    if (token is! String || token.isEmpty) {
      throw const FormatException('Missing token');
    }
    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Missing user');
    }

    return AuthSession(token: token, user: userFromJson(userJson));
  }
}

Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length < 2) {
    throw const FormatException('Invalid JWT');
  }

  final normalized = base64Url.normalize(parts[1]);
  return jsonDecode(utf8.decode(base64Url.decode(normalized)))
      as Map<String, dynamic>;
}

DateTime? jwtExpiryFromPayload(Map<String, dynamic> payload) {
  final exp = payload['exp'];
  if (exp is int) {
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
  }
  if (exp is String) {
    final parsed = int.tryParse(exp);
    if (parsed != null) {
      return DateTime.fromMillisecondsSinceEpoch(parsed * 1000, isUtc: true);
    }
  }
  return null;
}

bool isJwtExpired(
  String token, {
  DateTime? now,
  Duration leeway = _jwtExpiryLeeway,
}) {
  final expiry = jwtExpiryFromPayload(decodeJwtPayload(token));
  if (expiry == null) {
    return false;
  }

  final referenceTime = now?.toUtc() ?? DateTime.now().toUtc();
  return referenceTime.isAfter(expiry.subtract(leeway));
}

User userFromJwtPayload(Map<String, dynamic> payload) {
  final id = payload['sub']?.toString();
  final username = payload['username']?.toString();
  final role = payload['role']?.toString();

  if (id == null || id.isEmpty) {
    throw const FormatException('JWT payload missing sub');
  }
  if (username == null || username.isEmpty) {
    throw const FormatException('JWT payload missing username');
  }
  if (role == null || role.isEmpty) {
    throw const FormatException('JWT payload missing role');
  }

  final fullName =
      payload['full_name']?.toString() ??
      payload['fullName']?.toString() ??
      payload['name']?.toString() ??
      username;
  final branchId =
      payload['branch_id']?.toString() ?? payload['branchId']?.toString();

  return User(
    id: id,
    username: username,
    fullName: fullName,
    role: role,
    branchId: branchId,
  );
}

Map<String, dynamic> userToJson(User user) {
  return {
    'id': user.id,
    'username': user.username,
    'fullName': user.fullName,
    'role': user.role,
    if (user.branchId != null) 'branchId': user.branchId,
  };
}

User userFromJson(Map<String, dynamic> json) {
  final id = json['id']?.toString();
  final username = json['username']?.toString();
  final fullName = json['fullName']?.toString();
  final role = json['role']?.toString();

  if (id == null || id.isEmpty) {
    throw const FormatException('Stored user missing id');
  }
  if (username == null || username.isEmpty) {
    throw const FormatException('Stored user missing username');
  }
  if (fullName == null || fullName.isEmpty) {
    throw const FormatException('Stored user missing fullName');
  }
  if (role == null || role.isEmpty) {
    throw const FormatException('Stored user missing role');
  }

  return User(
    id: id,
    username: username,
    fullName: fullName,
    role: role,
    branchId: json['branchId']?.toString(),
  );
}
