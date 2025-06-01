import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../model/auth/token_refresh_request.dart';
import '../model/auth/auth_response.dart';
import '../model/default_response.dart';
import '../model/user/user.dart';
import '../service/admin_auth_service.dart';
import '../service/api_client.dart';

class AdminAuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final AdminAuthService _service;
  late final ApiClient _apiClient;

  bool get isLoaded => _isLoaded;

  bool _isLoaded = false;

  String? _token;
  String? _refreshToken;
  DateTime? _refreshExpiry;
  User? _user;

  AdminAuthProvider({required String baseUrl}) {
    _apiClient = ApiClient(
      baseUrl: baseUrl,
      getToken: () async {
        await ensureLoaded();
        return _token;
      },
      refreshToken: () async {
        await refreshTokens();
      },
    );
    _service = AdminAuthService(apiClient: _apiClient);
    _loadFromStorage();
  }

  String? get token => _token;

  String? get refreshToken => _refreshToken;

  DateTime? get refreshTokenExpiry => _refreshExpiry;

  User? get user => _user;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> ensureLoaded() async {
    if (!_isLoaded) {
      await _loadFromStorage();
      _isLoaded = true;
    }
  }

  Future<void> _loadFromStorage() async {
    _token = await _secureStorage.read(key: 'admin_token');
    _refreshToken = await _secureStorage.read(key: 'admin_refreshToken');
    final expiryStr = await _secureStorage.read(key: 'admin_refreshExpiry');
    final userJson = await _secureStorage.read(key: 'admin_user');

    if (expiryStr != null) {
      _refreshExpiry = DateTime.tryParse(expiryStr);
    }
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
    }

    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    if (_token != null &&
        _refreshToken != null &&
        _refreshExpiry != null &&
        _user != null) {
      await _secureStorage.write(key: 'admin_token', value: _token);
      await _secureStorage.write(
        key: 'admin_refreshToken',
        value: _refreshToken,
      );
      await _secureStorage.write(
        key: 'admin_refreshExpiry',
        value: _refreshExpiry!.toUtc().toIso8601String(),
      );
      await _secureStorage.write(
        key: 'admin_user',
        value: jsonEncode(_user!.toJson()),
      );
    }
  }

  Future<void> login(AuthenticationResponse resp) async {
    _token = resp.accessToken;
    _refreshToken = resp.refreshToken;
    _refreshExpiry = resp.refreshTokenExpiry;
    _user = resp.user;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> refreshTokens() async {
    if (_refreshToken == null) throw Exception("No refresh token");
    if (_refreshExpiry != null && DateTime.now().isAfter(_refreshExpiry!)) {
      await logout();
      return;
    }
    final req = TokenRefreshRequest(refreshToken: _refreshToken!);
    final resp = await _service.refresh(req);
    _token = resp.accessToken;
    _refreshToken = resp.refreshToken;
    _refreshExpiry = resp.refreshTokenExpiry;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _refreshExpiry = null;
    _user = null;
    await _secureStorage.deleteAll();
    notifyListeners();
  }

  Future<DefaultResponse> requestCode(String email) {
    return _service.requestCode(email);
  }

  Future<void> confirmCode(String email, String code) async {
    final resp = await _service.confirmCode(email, code);
    await login(resp);
  }
}
