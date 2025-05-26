
import '../user/user.dart';

class AuthenticationResponse {
  final String accessToken;
  final String refreshToken;
  final DateTime refreshTokenExpiry;
  final User user;

  AuthenticationResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpiry,
    required this.user,
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiry: DateTime.parse(json['refreshTokenExpiry'] as String),
      user: User.fromJson(json['user'] as Map<String,dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'refreshTokenExpiry': refreshTokenExpiry.toUtc().toIso8601String(),
    'user': user.toJson(),
  };
}
