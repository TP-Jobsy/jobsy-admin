import '../user/user.dart';
import 'client_profile_basic.dart';
import 'client_profile_contact.dart';
import 'client_profile_field.dart';

class ClientProfile {
  final int id;
  final ClientProfileBasic basic;
  final ClientProfileContact contact;
  final ClientProfileField field;
  final User user;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;
  final double averageRating;
  final int ratingCount;

  ClientProfile({
    required this.id,
    required this.basic,
    required this.contact,
    required this.field,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    required this.averageRating,
    required this.ratingCount,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? {};
    final userDto = User.fromJson(userMap);
    final basicRaw = Map<String, dynamic>.from(
      json['basic'] as Map<String, dynamic>? ?? {},
    );
    basicRaw['dateBirth'] = userDto.dateBirth;
    final basicDto = ClientProfileBasic.fromJson(basicRaw);
    return ClientProfile(
      id: json['id'] as int,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      basic: basicDto,
      contact: ClientProfileContact.fromJson(
        json['contact'] as Map<String, dynamic>? ?? {},
      ),
      field: ClientProfileField.fromJson(
        json['field'] as Map<String, dynamic>? ?? {},
      ),
      user: userDto,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'basic': basic.toJson(),
    'contact': contact.toJson(),
    'field': field.toJson(),
    'user': user.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'avatarUrl': avatarUrl,
    'averageRating': averageRating,
    'ratingCount': ratingCount,
  };
}