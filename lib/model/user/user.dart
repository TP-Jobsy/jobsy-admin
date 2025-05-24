class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String phone;
  final String dateBirth;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.phone,
    required this.dateBirth,
    required this.isActive,
    required this.createdAt,
  });

  User.fromId({required this.id})
    : firstName = '',
      lastName = '',
      email = '',
      phone = '',
      dateBirth = '',
      isActive = false,
      createdAt = DateTime.now(),
      role = '';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      phone: json['phone'],
      dateBirth: json['dateBirth'],
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

extension UserDtoSerialization on User {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'phone': phone,
      'dateBirth': dateBirth,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
