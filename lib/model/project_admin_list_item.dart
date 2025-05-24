class ProjectAdminListItem {
  final int id;
  final String title;
  final DateTime createdAt;
  final String status;
  final ClientInfo client;

  ProjectAdminListItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.status,
    required this.client,
  });

  factory ProjectAdminListItem.fromJson(Map<String, dynamic> json) {
    return ProjectAdminListItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      client: ClientInfo.fromJson(json['client'] as Map<String, dynamic>),
    );
  }
}

class ClientInfo {
  final String firstName;
  final String lastName;

  ClientInfo({
    required this.firstName,
    required this.lastName,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }
}