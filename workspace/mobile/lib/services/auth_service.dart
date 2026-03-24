import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../types/auth.dart';

const _tokenStorageKey = 'mobile_auth_token';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthGateway {
  Future<User> register(Credentials credentials);
  Future<User> login(Credentials credentials);
  Future<User> getCurrentUser();
  Future<void> logout();
}

class AuthService implements AuthGateway {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _baseUri = Uri.parse(
    const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8080'),
  );

  @override
  Future<User> register(Credentials credentials) async {
    final response = await _client.post(
      _baseUri.resolve('/api/auth/register'),
      headers: const {
        'Content-Type': 'application/json',
        'X-Client-Type': 'mobile',
      },
      body: jsonEncode(credentials.toJson()),
    );

    final payload = _decodeJson(response);
    if (response.statusCode != 200) {
      throw ApiException(payload['message'] as String? ?? 'Request failed.');
    }

    await _storeToken(payload['token'] as String);
    return User.fromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<User> login(Credentials credentials) async {
    final response = await _client.post(
      _baseUri.resolve('/api/auth/login'),
      headers: const {
        'Content-Type': 'application/json',
        'X-Client-Type': 'mobile',
      },
      body: jsonEncode(credentials.toJson()),
    );

    final payload = _decodeJson(response);
    if (response.statusCode != 200) {
      throw ApiException(payload['message'] as String? ?? 'Request failed.');
    }

    await _storeToken(payload['token'] as String);
    return User.fromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<User> getCurrentUser() async {
    final token = await _readToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Missing token');
    }

    final response = await _client.get(
      _baseUri.resolve('/api/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final payload = _decodeJson(response);
    if (response.statusCode != 200) {
      await _clearToken();
      throw ApiException(payload['message'] as String? ?? 'Request failed.');
    }

    return User.fromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    final token = await _readToken();
    if (token == null || token.isEmpty) {
      await _clearToken();
      return;
    }

    final response = await _client.post(
      _baseUri.resolve('/api/auth/logout'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      final payload = _decodeJson(response);
      throw ApiException(payload['message'] as String? ?? 'Logout failed.');
    }

    await _clearToken();
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.body.isEmpty) {
      return const {};
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenStorageKey, token);
  }

  Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenStorageKey);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenStorageKey);
  }
}
