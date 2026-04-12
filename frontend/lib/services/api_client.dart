import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

typedef UnauthorizedRecovery = Future<String?> Function();

class ApiClient {
  final String baseUrl;
  String? _token;
  final http.Client _client = http.Client();
  UnauthorizedRecovery? _unauthorizedRecovery;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
  bool get isAuthenticated => _token != null;
  void setUnauthorizedRecovery(UnauthorizedRecovery? recovery) =>
      _unauthorizedRecovery = recovery;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<dynamic> get(String path, {bool retryOnUnauthorized = true}) async {
    final response = await _send(
      () => _client.get(Uri.parse('$baseUrl$path'), headers: _headers),
      retryOnUnauthorized: retryOnUnauthorized,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool retryOnUnauthorized = true,
  }) async {
    final response = await _send(
      () => _client.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ),
      retryOnUnauthorized: retryOnUnauthorized,
    );
    return _handleResponse(response);
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    required bool retryOnUnauthorized,
  }) async {
    var response = await request();
    if (response.statusCode != 401 ||
        !retryOnUnauthorized ||
        _unauthorizedRecovery == null) {
      return response;
    }

    final refreshedToken = await _unauthorizedRecovery!.call();
    if (refreshedToken == null || refreshedToken.isEmpty) {
      return response;
    }

    response = await request();
    return response;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    final message = body['message'] ?? 'Request failed';
    throw ApiException(response.statusCode, message.toString());
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
