import '../user/user.dart';

class AuthenticationResponse {
  final String token;
  final User user;

  AuthenticationResponse({
    required this.token,
    required this.user,
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'user': user.toJson(),
  };
}
