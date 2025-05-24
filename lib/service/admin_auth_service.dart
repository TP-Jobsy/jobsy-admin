import '../model/auth/auth_response.dart';
import '../model/default_response.dart';
import 'api_client.dart';

class AdminAuthService {
  final ApiClient _api;

  AdminAuthService({required ApiClient apiClient})
      : _api = apiClient;

  Future<DefaultResponse> requestCode(String email) {
    return _api.post<DefaultResponse>(
      '/admin/auth/login',
      body: {'email': email},
      decoder: (json) => DefaultResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<AuthenticationResponse> confirmCode(
      String email,
      String confirmationCode,
      ) {
    return _api.post<AuthenticationResponse>(
      '/admin/auth/confirm',
      body: {
        'email': email,
        'confirmationCode': confirmationCode,
      },
      decoder: (json) => AuthenticationResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}