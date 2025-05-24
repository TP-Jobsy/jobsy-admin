import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/default_response.dart';
import '../service/admin_auth_service.dart';
import '../service/api_client.dart';

class AdminAuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AdminAuthService _service;

  bool _isLoaded = false;
  String? _token;

  AdminAuthProvider({required String baseUrl})
    : _service = AdminAuthService(apiClient: ApiClient(baseUrl: baseUrl)) {
    _loadFromStorage();
  }

  String? get token => _token;

  bool get isLoggedIn => _token != null;

  Future<void> _loadFromStorage() async {
    _token = await _secureStorage.read(key: 'admin_jwt_token');
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    await _secureStorage.write(key: 'admin_jwt_token', value: token);
    notifyListeners();
  }

  Future<DefaultResponse> requestCode(String email) {
    return _service.requestCode(email);
  }

  Future<void> confirmCode(String email, String code) async {
    final resp = await _service.confirmCode(email, code);
    await _saveToken(resp.token);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'admin_jwt_token');
    _token = null;
    notifyListeners();
  }
}
