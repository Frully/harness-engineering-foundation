import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

abstract class TokenStore {
  Future<void> writeToken(String token);
  Future<String?> readToken();
  Future<void> clearToken();
}

class SecureTokenStore implements TokenStore {
  const SecureTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> clearToken() {
    return _storage.delete(key: _tokenStorageKey);
  }

  @override
  Future<String?> readToken() {
    return _storage.read(key: _tokenStorageKey);
  }

  @override
  Future<void> writeToken(String token) {
    return _storage.write(key: _tokenStorageKey, value: token);
  }
}

class InMemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async {
    _token = token;
  }
}

class AuthService implements AuthGateway {
  AuthService({Dio? client, TokenStore? tokenStore})
    : _client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              validateStatus: (_) => true,
              headers: const {'Content-Type': 'application/json'},
            ),
          ),
      _tokenStore = tokenStore ?? const SecureTokenStore();

  final Dio _client;
  final TokenStore _tokenStore;

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  @override
  Future<User> register(Credentials credentials) async {
    final payload = await _authenticate('/api/auth/register', credentials);
    await _storeToken(payload['token'] as String);
    return User.fromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<User> login(Credentials credentials) async {
    final payload = await _authenticate('/api/auth/login', credentials);
    await _storeToken(payload['token'] as String);
    return User.fromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<User> getCurrentUser() async {
    final payload = await _request(
      method: 'GET',
      path: '/api/me',
      headers: await _authorizationHeaders(),
      clearTokenOnFailure: true,
    );

    return User.fromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    final token = await _readToken();
    if (token == null || token.isEmpty) {
      await _clearToken();
      return;
    }

    await _request(
      method: 'POST',
      path: '/api/auth/logout',
      headers: {'Authorization': 'Bearer $token'},
      expectedStatus: 204,
      failureMessage: 'Logout failed.',
    );
    await _clearToken();
  }

  Future<Map<String, dynamic>> _authenticate(
    String path,
    Credentials credentials,
  ) {
    return _request(
      method: 'POST',
      path: path,
      data: credentials.toJson(),
      headers: const {'X-Client-Type': 'mobile'},
    );
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Object? data,
    Map<String, String>? headers,
    int expectedStatus = 200,
    String failureMessage = 'Request failed.',
    bool clearTokenOnFailure = false,
  }) async {
    final response = await _client.request<dynamic>(
      path,
      data: data,
      options: Options(method: method, headers: headers),
    );

    final payload = _decodeJson(response);
    if (response.statusCode != expectedStatus) {
      if (clearTokenOnFailure) {
        await _clearToken();
      }
      throw ApiException(payload['message'] as String? ?? failureMessage);
    }

    return payload;
  }

  Future<Map<String, String>> _authorizationHeaders() async {
    final token = await _readToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Missing token');
    }

    return {'Authorization': 'Bearer $token'};
  }

  Map<String, dynamic> _decodeJson(Response<dynamic> response) {
    final data = response.data;
    if (data == null) {
      return const {};
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String && data.isNotEmpty) {
      return _decodeStringPayload(data);
    }
    return const {};
  }

  Map<String, dynamic> _decodeStringPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } on FormatException {
      return const {};
    }
    return const {};
  }

  Future<void> _storeToken(String token) {
    return _tokenStore.writeToken(token);
  }

  Future<String?> _readToken() {
    return _tokenStore.readToken();
  }

  Future<void> _clearToken() {
    return _tokenStore.clearToken();
  }
}
